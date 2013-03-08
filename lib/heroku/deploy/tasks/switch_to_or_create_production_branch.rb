module Heroku::Deploy::Task
  class SwitchToOrCreateProductionBranch < Base
    include Heroku::Deploy::Shell

    def before_push
      raise 'blah'
    end
  end
end
