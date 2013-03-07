module Heroku::Deploy::Task
  class Base
    attr_accessor :strategy, :app

    def initialize(strategy)
      @strategy = strategy
      @app      = strategy.app
    end

    def rollback_before_push; end
    def before_push; end

    def rollback_after_push; end
    def after_push; end
  end
end
