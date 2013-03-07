module Heroku::Deploy::Task
  class UnsafeMigration < Base
    def before_push
      #unless heroku_app.is_staging?
        #info "Also, because we're not on staging, we should disable preboot"
        #api.delete_feature :preboot, app
      #end
      raise 'unsafe migration'
      api.post_app_maintenance(app, '1')
    end

    def after_push
      DatabaseMigrate.new(strategy).perform
      api.post_app_maintenance(app, '0')
      #unless heroku_app.is_staging?
        #info "Because this isn't staging, I'm going to turn preboot back on. Like a boss!"
        #api.post_feature :preboot, app
      #end
    end
  end
end
