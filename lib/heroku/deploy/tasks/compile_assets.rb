module Heroku::Deploy::Task
  class CompileAssets < Base
    def before_push
      raise 'compile assets!'
    end
  end
end
