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
    def self.build_from_delta(delta, app_data, api)
      task_klasses = [ Task::StashGitChanges ]

      if delta.has_asset_changes?
        task_klasses << Task::CompileAssets
      else
        task_klasses << Task::StealManifest
      end

      task_klasses << Task::CommitManifest

      if delta.has_unsafe_migrations?
        task_klasses << Task::UnsafeMigration
      elsif delta.has_migrations?
        task_klasses << Task::SafeMigration
      end

      new delta, app_data, api, task_klasses
    end

    attr_accessor :delta, :app_data, :api, :task_klasses

    def initialize(delta, app_data, api, task_klasses)
      @delta        = delta
      @app_data     = app_data
      @api          = api
      @task_klasses = task_klasses
    end

    def perform
      tasks.each &:before_push
      Task::PushCode.new(app_data, api).perform
      tasks.each &:after_push
    end

    private

    def tasks
      @tasks ||= @task_klasses.map { |klass| instantiate_task klass }
    end

    def instantiate_task(klass)
      klass.new(self)
    end
  end
end
