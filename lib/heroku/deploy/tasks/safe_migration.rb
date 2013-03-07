module Heroku::Deploy::Task
  class SafeMigration < Base
    def before_push
      DatabaseMigrate.new(strategy).perform
    end
  end
end
