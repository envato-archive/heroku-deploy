require_relative "task_runner"
require_relative "tasks/base"
require_relative "tasks/stash_git_changes"
require_relative "tasks/compile_assets"
require_relative "tasks/steal_manifest"
require_relative "tasks/commit_manifest"
require_relative "tasks/safe_migration"
require_relative "tasks/database_migrate"
require_relative "tasks/push_code"
require_relative "tasks/unsafe_migration"

module Heroku::Deploy
  class Strategy
    include UI

    def self.perform_from_delta(delta, app)
      tasks = [ Task::StashGitChanges ]

      # Always compile assets for now
      tasks << Task::CompileAssets

      #if delta.has_asset_changes?
        #tasks << Task::CompileAssets
      #else
        #tasks << Task::StealManifest
      #end

      tasks << Task::CommitManifest

      if delta.has_unsafe_migrations?
        tasks << Task::UnsafeMigration
      elsif delta.has_migrations?
        tasks << Task::SafeMigration
      end

      new(delta, app, tasks).perform
    end

    attr_accessor :delta, :commit, :app, :tasks

    def initialize(delta, app, tasks)
      @delta  = delta
      @commit = delta.to
      @app    = app
      @tasks  = tasks.map { |task| task.new(self) }
    end

    def task_runner
      @task_runner ||= TaskRunner.new(tasks)
    end

    def perform
      task_runner.perform_method :before_push
      Task::PushCode.new(self).perform
      task_runner.perform_method_in_reverse :after_push
    end
  end
end
