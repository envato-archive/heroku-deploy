module Heroku::Deploy::Task
  class UnsafeMigration < Base
    include Heroku::Deploy::UI

    def before_deploy
      task "Turning on maintenance mode" do
        app.enable_maintenance
      end

      DatabaseMigrate.migrate(strategy)
    end

    def rollback_before_deploy
      after_deploy
    end

    def after_deploy
      task "Turning off maintenance mode" do
        app.disable_maintenance
      end
    end
  end
end
