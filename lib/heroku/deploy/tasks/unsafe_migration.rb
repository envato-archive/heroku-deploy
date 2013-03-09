module Heroku::Deploy::Task
  class UnsafeMigration < Base
    include Heroku::Deploy::UI

    def before_deploy
      task "Checking if preboot is enabled" do
        @preboot = app.feature_enabled? :preboot
      end

      if @preboot
        task "Disabling preboot while we run migrations" do
          app.disable_feature :preboot
        end
      end

      task "Turning on maintenance mode" do
        app.enable_maintenance
      end
    end

    def after_deploy
      DatabaseMigrate.migrate(strategy)

      task "Turning off maintenance mode" do
        app.disable_maintenance
      end

      if @preboot
        task "Enabling preboot again" do
          app.enable_feature :preboot
        end
      end
    end
  end
end
