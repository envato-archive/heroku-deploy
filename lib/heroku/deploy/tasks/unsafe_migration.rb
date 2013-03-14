module Heroku::Deploy::Task
  class UnsafeMigration < Base
    include Heroku::Deploy::UI

    def before_deploy
      task "Turn off preboot if its enabled" do
        @preboot = app.feature_enabled? :preboot

        if @preboot
          app.disable_feature :preboot
        end
      end

      task "Turning on maintenance mode" do
        app.enable_maintenance
      end

      DatabaseMigrate.migrate(strategy)
    end

    def after_deploy
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
