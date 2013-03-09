require_relative "task_runner"
require_relative "tasks/base"
require_relative "tasks/stash_git_changes"
require_relative "tasks/prepare_production_branch"
require_relative "tasks/compile_assets"
require_relative "tasks/commit_assets"
require_relative "tasks/safe_migration"
require_relative "tasks/database_migrate"
require_relative "tasks/push_code"
require_relative "tasks/unsafe_migration"

module Heroku::Deploy
  class Strategy
    include UI

    def self.perform_from_delta(delta, app)
      new(delta, app).perform
    end

    attr_accessor :delta, :commit, :app

    def initialize(delta, app)
      @delta = delta
      @app   = app
    end

    def commit
      delta.to
    end

    def branch
      "heroku-deploy/#{app.name}"
    end

    def tasks
      tasks = [
        Task::StashGitChanges.new(self),
        Task::PrepareProductionBranch.new(self)
      ]

      if delta.has_asset_changes?
        tasks << Task::CompileAssets.new(self)
        tasks << Task::CommitAssets.new(self)
      end

      if delta.has_unsafe_migrations?
        tasks << Task::UnsafeMigration.new(self)
      elsif delta.has_migrations?
        tasks << Task::SafeMigration.new(self)
      end

      tasks << Task::PushCode.new(self)

      tasks
    end

    def task_runner
      @task_runner ||= TaskRunner.new(tasks)
    end

    def perform
      TaskRunner.new(tasks).perform_methods :before_deploy, :deploy, :after_deploy
    end
  end
end
