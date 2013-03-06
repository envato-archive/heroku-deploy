require "heroku/deploy/ui"
require "heroku/deploy/shell"
require "heroku/deploy/heroku_app"
require "heroku/deploy/git_local"
require "heroku/deploy/git_remote"

module Heroku::Deploy
  class Runner
    include Shell

    def self.deploy(app, api)
      new(app, api).deploy
    end

    attr_accessor :app, :api, :config, :heroku_app, :local_git, :deploy_ref

    def initialize(app, api)
      @app = app
      @api = api

      @heroku_app = HerokuApp.new app
      @local_git = GitLocal.new

      @deploy_ref = ENV["GIT_COMMIT"] || 'HEAD'
      error "Missing GIT_COMMIT" unless @deploy_ref
    end

    def config
      @config ||= @api.get_config_vars(@app).body
    end

    def update_local_repo_to_latest
      local_git.fetch
    end

    def find_commit_sha_for_ref
      commit_sha = local_git.commit_sha :ref => deploy_ref

      unless commit_sha
        error "Couldn't figure out the full commit SHA for `#{deploy_ref}`"
      end

      commit_sha
    end


    def has_migrations?(diff)
      diff.match(/ActiveRecord::Migration/)
    end

    def has_unsafe_migrations?(diff)
      has_migrations?(diff) && diff.match(/change_column|change_table|drop_table|remove_column|remove_index|rename_column|execute/)
    end

    def migrate_database
      info "Checking out to the correct commit locally"
      current_branch = local_git.current_branch
      local_git.checkout deploy_ref

      info "Migrating..."
      heroku_app.migrate!

      info "Search database setup..."
      heroku_app.prepare_search_database!

      info "Returning repo to its previous state"
      local_git.checkout current_branch
    end

    def prepare_for_unsafe_migration
      info "So this deploy has UNSAFE migrations. Lets do the maintenance thing."
      heroku_app.maintenance! :on

      unless heroku_app.is_staging?
        info "Also, because we're not on staging, we should disable preboot"
        heroku_app.labs! :preboot, :disable
      end
    end

    def finalize_unsafe_migration
      migrate_database

      info "Turning off maintenance mode"
      heroku_app.maintenance! :off

      unless heroku_app.is_staging?
        info "Because this isn't staging, I'm going to turn preboot back on. Like a boss!"
        heroku_app.labs! :preboot, :enable
      end
    end

    def push_to_heroku(commit_sha)
      local_git.push_to :remote => heroku_app.git_remote, :ref => commit_sha

      api.put_config_vars app, { 'DEPLOYED_COMMIT' => commit_sha }
    end

    def deploy
      info <<-OUT
       _            _             _
    __| | ___ _ __ | | ___  _   _(_)_ __   __ _
   / _` |/ _ \\ '_ \\| |/ _ \\| | | | | '_ \\ / _` |
  | (_| |  __/ |_) | | (_) | |_| | | | | | (_| |
   \\__,_|\\___| .__/|_|\\___/ \\__, |_|_| |_|\\__, |
               |_|          |___/         |___/
      OUT

      info "First, lets make sure your local git repo is up to date"
      update_local_repo_to_latest

      info "Finding the local commit sha for (#{deploy_ref})"
      commit_sha = find_commit_sha_for_ref
      ok "It's #{commit_sha}. Moving on.."

      info "Finding out what is deployed on #{heroku_app.git.repo}"
      last_commit = config['DEPLOYED_COMMIT']

      if !last_commit.empty?
        ok "Found it! #{last_commit}"
        info "Deploying #{last_commit}..#{commit_sha}"
      elsif last_commit == commit_sha
        finish "Nothing to deploy! Thanks for playing :D:D"
      else
        info "No previous commit found. Treating it like a new deploy"
      end

      if !last_commit.empty?
        diff = local_git.diff :from => last_commit, :to => commit_sha

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

      info "Pushing code to #{heroku_app.git_remote}"
      push_to_heroku commit_sha

      if !last_commit.empty?
        if has_unsafe_migrations?(diff)
          finalize_unsafe_migration
        end
      end

      finish "Finished! Thanks for playing."
    end
  end
end
