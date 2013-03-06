require "heroku/deploy/ui"
require "heroku/deploy/shell"
require "heroku/deploy/heroku_app"
require "heroku/deploy/git_local"

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
      @git = GitLocal.new
    end

    def app_data
      @app_data ||= api.get_app(app).body
    end

    def config
      @config ||= api.get_config_vars(app).body
    end

    def deploy_sha

    end

    def has_migrations?(diff)
      diff.match(/ActiveRecord::Migration/)
    end

    def has_unsafe_migrations?(diff)
      has_migrations?(diff) && diff.match(/change_column|change_table|drop_table|remove_column|remove_index|rename_column|execute/)
    end

    def migrate_database
      info "Checking out to the correct commit locally"
      current_branch = git.current_branch
      git.checkout deploy_ref

      info "Migrating..."
      heroku_app.migrate!

      info "Search database setup..."
      heroku_app.prepare_search_database!

      info "Returning repo to its previous state"
      git.checkout current_branch
    end

    def prepare_for_unsafe_migration
      info "So this deploy has UNSAFE migrations. Lets do the maintenance thing."
      api.post_app_maintenance(app, '1')

      unless heroku_app.is_staging?
        info "Also, because we're not on staging, we should disable preboot"
        api.delete_feature :preboot, app
      end
    end

    def finalize_unsafe_migration
      migrate_database

      info "Turning off maintenance mode"
      api.post_app_maintenance(app, '0')

      unless heroku_app.is_staging?
        info "Because this isn't staging, I'm going to turn preboot back on. Like a boss!"
        api.post_feature :preboot, app
      end
    end

    def push_to_heroku(git_url, commit_sha)
      git.push_to :remote => git_url, :ref => commit_sha

      api.put_config_vars app, { 'DEPLOYED_COMMIT' => commit_sha }
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
      last_commit = config['DEPLOYED_COMMIT']

      info "Calculating deploy deltas"

      if !last_commit.empty?
        ok "Found it! #{last_commit}"
        info "Deploying #{last_commit}..#{commit}"
      elsif last_commit == commit
        finish "Nothing to deploy! Thanks for playing :D:D"
      else
        info "No previous commit found. Treating it like a new deploy"
      end

      if !last_commit.empty?
        diff = git.diff :from => last_commit, :to => commit

        if has_migrations?(diff)
          if has_unsafe_migrations?(diff)
            prepare_for_unsafe_migration
          else
            info "So looks like we've just got SAFE migrations this deploy. Lets do the migrations before we deploy."
            migrate_database
          end
        else
          info "No migrations for this deploy. This is going to be easy..."
        end
      end

      info "Pushing #{commit} to #{git_url}"
      push_to_heroku git_url, commit

      if !last_commit.empty?
        if has_unsafe_migrations?(diff)
          finalize_unsafe_migration
        end
      end

      finish "Finished! Thanks for playing."
    end
  end
end
