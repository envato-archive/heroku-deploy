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
      tasks = [
        Task::StashGitChanges,
        Task::PrepareProductionBranch
      ]

      if delta.has_asset_changes? || delta.missing_assets?
        tasks << Task::CompileAssets
        tasks << Task::CommitAssets
      end

      if delta.has_unsafe_migrations?
        tasks << Task::UnsafeMigration
      elsif delta.has_migrations?
        tasks << Task::SafeMigration
      end

      tasks << Task::PushCode

      new(delta, app, tasks).perform
    end

    attr_accessor :delta, :commit, :app, :tasks

    def initialize(delta, app, tasks)
      @delta  = delta
      @commit = delta.to
      @app    = app
      @tasks  = tasks.map { |task| task.new(self) }
    end

    def branch
      "heroku-deploy/#{app.name}"
    end

    def task_runner
      @task_runner ||= TaskRunner.new(tasks)
    end

    def perform
      task_runner.perform_methods :before_deploy, :deploy, :after_deploy
    end
  end
end
