module Heroku::Deploy::Task
  class Base
    attr_accessor :strategy, :app

    def initialize(strategy)
      @strategy = strategy
      @app      = strategy.app
    end

    def rollback_before_deploy; end
    def before_deploy; end

    def deploy; end
    def rollback_deploy; end

    def rollback_after_deploy; end
    def after_deploy; end
  end
end
