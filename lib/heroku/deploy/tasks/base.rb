module Heroku::Deploy::Task
  class Base
    attr_accessor :strategy

    def initialize(strategy)
      @strategy = strategy
    end

    def app_data
      @strategy.app_data
    end

    def api
      @strategy.api
    end

    def rollback_before_push
    end

    def before_push
    end

    def rollback_after_push
    end

    def after_push
    end

    def perform
    end
  end
end
