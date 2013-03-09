module Heroku::Deploy::Task
  class DatabaseMigrate < Base
    include Heroku::Deploy::Shell

    def self.migrate(strategy)
      new(strategy).migrate
    end

    def migrate
      env_vars = app.env.dup
      env_vars['RAILS_ENV'] = 'production'

      task "Migrating the database remotely"
      shell "bundle exec rake db:migrate", :env => env_vars, :exec => true
    end
  end
end
