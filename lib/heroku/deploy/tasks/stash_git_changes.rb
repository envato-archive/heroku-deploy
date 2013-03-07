module Heroku::Deploy::Task
  class StashGitChanges < Base
    def before_push
      raise 'git stash'
    end

    def after_push
      raise 'git stash apply'
    end
  end
end
