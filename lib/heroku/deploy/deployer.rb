require "heroku/deploy/app"
require "heroku/deploy/ui"
require "heroku/deploy/shell"
require "heroku/deploy/runner"
require "heroku/deploy/diff"

require "heroku/deploy/tasks/base"
require "heroku/deploy/tasks/lock"
require "heroku/deploy/tasks/stash_git_changes"
require "heroku/deploy/tasks/prepare_production_branch"
require "heroku/deploy/tasks/compile_assets"
require "heroku/deploy/tasks/commit_assets"
require "heroku/deploy/tasks/safe_migration"
require "heroku/deploy/tasks/database_migrate"
require "heroku/deploy/tasks/push_code"
require "heroku/deploy/tasks/unsafe_migration"

require "heroku/deploy/strategies/base"
require "heroku/deploy/strategies/delta"
require "heroku/deploy/strategies/setup"

module Heroku::Deploy
  class Deployer
    include Shell

    def self.deploy(app)
      new(app).deploy
    end

    attr_accessor :app, :git_url, :new_commit, :deployed_commit

    def initialize(app)
      @app = app
    end

    def branch
      "heroku-deploy/#{app.name}"
    end

    def commit_key
      'HEROKU_DEPLOY_COMMIT'
    end

    def deploy
      banner <<-OUT
      _            _             _
   __| | ___ _ __ | | ___  _   _(_)_ __   __ _
  / _` |/ _ \\ '_ \\| |/ _ \\| | | | | '_ \\ / _` |
 | (_| |  __/ |_) | | (_) | |_| | | | | | (_| |
  \\__,_|\\___| .__/|_|\\___/ \\__, |_|_| |_|\\__, |
              |_|          |___/         |___/
      OUT

      task "Gathering information about the deploy" do
        self.git_url    = app.git_url
        self.new_commit = git %{rev-parse --verify HEAD}
      end

      task "Looking for #{colorize commit_key, :cyan} on #{colorize git_url, :cyan}" do
        self.deployed_commit = app.env[commit_key]
      end

      if deployed_commit && !deployed_commit.empty?
        Strategy::Delta.perform self
      else
        Strategy::Setup.perform self
      end

      task "Updating #{colorize commit_key, :cyan}"
      app.put_config_vars commit_key => new_commit

      finish "Finished! Thanks for playing."
    end
  end
end
