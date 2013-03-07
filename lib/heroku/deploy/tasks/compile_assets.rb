module Heroku::Deploy::Task
  class CompileAssets < Base
    def before_push
      raise env.inspect
    end
  end
end
