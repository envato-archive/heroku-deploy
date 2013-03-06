module Heroku::Deploy
  class Strategy::DeployWithSafeMigration < Strategy::DeployWithUnsafeMigration
    def perform
      migrate_database && push_code
    end
  end
end
