module Heroku::Deploy::Task
  class CommitManifest < Base
    def before_push
      raise 'commit manifest'
    end
  end
end
