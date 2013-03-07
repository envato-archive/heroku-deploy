module Heroku::Deploy::Task
  class DatabaseMigrate < Base
    def git
      @git ||= Git.new
    end

    def perform
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
end
