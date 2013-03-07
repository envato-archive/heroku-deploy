require "heroku/deploy/ui"
require "heroku/deploy/shell"
require "heroku/deploy/git"
require "heroku/deploy/delta"
require "heroku/deploy/strategy"

module Heroku::Deploy
  class Runner
    include Shell

    def self.deploy(app, api)
      new(app, api).deploy
    end

    attr_accessor :app, :api, :heroku_app

    def initialize(app, api)
      @api = api
      @app = app
    end

    def git
      @git ||= Git.new
    end

    def app_data
      @app_data ||= api.get_app(app).body
    end

    def env
      @env ||= api.get_config_vars(app).body
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


      new_commit, git_url = nil
      task "Gathering information about the deploy" do
        new_commit = git.sha_for_ref 'HEAD'
        git_url = app_data['git_url']
      end

      deployed_commit = nil
      task "Querying #{colorize git_url, :cyan} for latest deployed commit" do
        deployed_commit = env['DEPLOYED_COMMIT']
      end

      delta = nil
      difference = "#{deployed_commit[0..7]}..#{new_commit[0..7]}"
      task "Determining deploy strategy for #{colorize difference, :cyan}" do
        delta = Delta.calcuate_from deployed_commit, new_commit
      end

      strategy = Strategy.build_from_delta delta, self
      task "Deploying with #{colorize strategy.class.name, :cyan}"
      strategy.perform

      finish "Finished! Thanks for playing."
    end
  end
end
