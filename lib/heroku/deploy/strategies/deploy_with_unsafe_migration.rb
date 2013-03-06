module Heroku::Deploy
  class Strategy::DeployWithUnsafeMigration < Strategy::DeployToHeroku
    def migrate_database
      info "Migrating..."
      heroku_app.migrate!

      info "Search database setup..."
      heroku_app.prepare_search_database!

      info "Returning repo to its previous state"
      git.checkout current_branch
    end

    def perform
      info "So this deploy has UNSAFE migrations. Lets do the maintenance thing."
      api.post_app_maintenance(app, '1')

      unless heroku_app.is_staging?
        info "Also, because we're not on staging, we should disable preboot"
        api.delete_feature :preboot, app
      end

      push_code

      migrate_database

      info "Turning off maintenance mode"
      api.post_app_maintenance(app, '0')

      unless heroku_app.is_staging?
        info "Because this isn't staging, I'm going to turn preboot back on. Like a boss!"
        api.post_feature :preboot, app
      end
    end
  end

  def prepare_search_database!
    remote_database_shell %{rake db:search:prepare}, :exec => true
  end

  def migrate!
    remote_database_shell %{rake db:migrate}, :exec => true
  end

  private

  def remote_database_shell(cmd, options = {})
    rails_env    = config('RAILS_ENV')
    database_url = config('DATABASE_URL')

    heroku_shell %{DATABASE_URL=#{database_url} RAILS_ENV=#{rails_env} #{cmd}}, options
  end

  def heroku_shell(cmd, options={})
    output = shell "#{cmd} --app #{app_name}", options

    unless options[:exec]
      if output.match /Authentication failure/
        error "Arrgh! I couldnt perform this heroku command.\n#{output}"
      end
    end

    output
  end
end
