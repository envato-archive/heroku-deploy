module Heroku::Deploy::Task
  class Base
    attr_accessor :strategy, :runner

    def initialize(strategy)
      @strategy = strategy
      @runner   = strategy.runner
    end

    def rollback_before_push; end
    def before_push; end

    def rollback_after_push; end
    def after_push; end
  end
end
