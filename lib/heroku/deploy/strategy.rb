module Heroku::Deploy
  class Strategy
    def self.build_from_delta(delta, app_data, api)
      klass = if delta.has_unsafe_migrations?
                Strategy::DeployWithUnsafeMigration
              elsif delta.has_migrations?
                Strategy::DeployWithSafeMigration
              else
                Strategy::DeployToHeroku
              end

      klass.new delta.to, app_data, api
    end
  end
end

require "heroku/deploy/strategies/deploy_to_heroku"
require "heroku/deploy/strategies/deploy_with_unsafe_migration"
require "heroku/deploy/strategies/deploy_with_safe_migration"
