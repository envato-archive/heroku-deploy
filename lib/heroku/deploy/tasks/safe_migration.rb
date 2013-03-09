module Heroku::Deploy::Task
  class SafeMigration < Base
    def before_deploy
      DatabaseMigrate.migrate(strategy)
    end
  end
end
