require "heroku/deploy/ui"
require "heroku/deploy/shell"
require "heroku/deploy/heroku_app"
require "heroku/deploy/git"
require "heroku/deploy/delta"
require "heroku/deploy/strategy"

module Heroku::Deploy
  class Runner
    include Shell

    def self.deploy(app, api)
      new(app, api).deploy
    end

    attr_accessor :app, :api, :git, :heroku_app

    def initialize(app, api)
      @api = api
      @app = app

      @heroku_app = HerokuApp.new app
      @git = Git.new
    end

    def app_data
      @app_data ||= api.get_app(app).body
    end

    def config
      @config ||= api.get_config_vars(app).body
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

      info "Gathering information about the deploy"
      commit = git.sha_for_ref 'HEAD'
      git_url = app_data['git_url']

      info "Finding out what is deployed on #{git_url}"
      deployed_commit = config['DEPLOYED_COMMIT']

      info "Determining deploy strategy"
      delta = Delta.calcuate_from commit, deployed_commit

      info "Performing deploy"
      strategy = Strategy.build_from_delta delta, app_data, api
      strategy.perform

      finish "Finished! Thanks for playing."
    end
  end
end
