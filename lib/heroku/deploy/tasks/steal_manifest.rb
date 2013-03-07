module Heroku::Deploy::Task
  class StealManifest < Base
    def before_push
      raise 'steal manifest'
    end
  end
end
