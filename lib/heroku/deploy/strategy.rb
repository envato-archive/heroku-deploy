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
      tasks = [ Task::StashGitChanges.new(self) ]

      if false
      if delta.has_asset_changes?
        tasks << Task::CompileAssets.new(self)
      else
        tasks << Task::StealManifest.new(self)
      end

      tasks << Task::CommitManifest.new(self)

      if delta.has_unsafe_migrations?
        tasks << Task::UnsafeMigration.new(self)
      elsif delta.has_migrations?
        tasks << Task::SafeMigration.new(self)
      end
      end

      new delta, app_data, api, tasks
    end

    attr_accessor :delta, :app_data, :api, :tasks

    def initialize(delta, app_data, api, tasks)
      @delta    = delta
      @app_data = app_data
      @api      = api
      @tasks    = tasks
    end

    def perform
      tasks.each &:before_push
      # Task::PushCode.new(app_data, api).perform
      tasks.each &:after_push
    end
  end
end
