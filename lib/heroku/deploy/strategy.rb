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

      if delta.has_asset_changes?
        tasks << Task::CompileAssets
      else
        tasks << Task::StealManifest
      end

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

    def perform
      perform_tasks tasks, :before_push
      Task::PushCode.new(self).perform
      perform_tasks tasks.reverse, :after_push
    end

    private

    def perform_tasks(tasks, action)
      performed_tasks = []
      current_task = nil

      begin
        tasks.each do |task|
          current_task = task
          current_task.public_send action

          performed_tasks << current_task
        end
      rescue Exception => e
        warning "An error occured when performing #{current_task.class.name}. Rolling back"

        performed_tasks.reverse.each do |task|
          task.public_send "rollback_#{action.to_s}"
        end

        raise e
      end
    end
  end
end
