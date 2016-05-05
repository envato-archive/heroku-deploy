module Heroku::Deploy::Task
  class PushToHeroku < Base
    include Heroku::Deploy::Shell

    def deploy
      git_url = app.git_url

      task "Pushing #{colorize strategy.branch, :cyan} to #{colorize "#{git_url}:master", :cyan}"
      git "push -f #{git_url} #{strategy.branch}:master -v", :exec => true
    end
  end
end
