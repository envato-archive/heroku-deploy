module Heroku::Deploy::Task
  class PushToOrigin < Base
    include Heroku::Deploy::Shell

    def deploy
      task "Pushing local #{colorize strategy.branch, :cyan} to #{colorize "origin", :cyan}"
      git "push -u origin #{strategy.branch} -v", :exec => true
    end
  end
end
