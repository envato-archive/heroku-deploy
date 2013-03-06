module Heroku::Deploy
  class Strategy::DeployWithUnsafeMigration < Strategy::DeployToHeroku
    def migrate_database
      remote_database_shell %{rake db:migrate}, :exec => true
    end

    def perform
      api.post_app_maintenance(app, '1')

      #unless heroku_app.is_staging?
        #info "Also, because we're not on staging, we should disable preboot"
        #api.delete_feature :preboot, app
      #end

      push_code

      migrate_database

      api.post_app_maintenance(app, '0')

      #unless heroku_app.is_staging?
        #info "Because this isn't staging, I'm going to turn preboot back on. Like a boss!"
        #api.post_feature :preboot, app
      #end
    end
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
