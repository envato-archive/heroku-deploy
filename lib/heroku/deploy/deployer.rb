require "heroku/deploy/app"
require "heroku/deploy/ui"
require "heroku/deploy/shell"
require "heroku/deploy/git"
require "heroku/deploy/delta"
require "heroku/deploy/strategy"

module Heroku::Deploy
  class Deployer
    include Shell

    def self.deploy(app)
      new(app).deploy
    end

    attr_accessor :app

    def initialize(app)
      @app = app
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
        new_commit = git %{rev-parse --verify HEAD}
        git_url = app.git_url
      end

      deployed_commit = nil
      task "Querying #{colorize git_url, :cyan} for latest deployed commit" do
        deployed_commit = app.env['DEPLOYED_COMMIT']
      end

      delta = nil
      difference = "#{chop_sha deployed_commit}..#{chop_sha new_commit}"
      task "Determining deploy strategy for #{colorize difference, :cyan}" do
        delta = Delta.calcuate_from deployed_commit, new_commit
      end

      Strategy.perform_from_delta delta, app

      finish "Finished! Thanks for playing."
    end
  end
end
