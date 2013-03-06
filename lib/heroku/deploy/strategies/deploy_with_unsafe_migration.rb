module Heroku::Deploy
  class Strategy::DeployWithUnsafeMigration < Strategy::DeployToHeroku
    def migrate_database
      info "Checking out to the correct commit locally"
      current_branch = git.current_branch
      git.checkout deploy_ref

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
end
