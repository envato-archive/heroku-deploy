module Heroku::Deploy::Task
  class PushCode < Base
    include Heroku::Deploy::Shell

    def deploy
      git_url = app.git_url

      task "Pushing #{colorize strategy.branch, :cyan} to #{colorize "#{git_url}:master", :cyan}"
      git "push #{git_url} #{strategy.branch}:master -v", :exec => true

      app.put_config_vars 'DEPLOYED_COMMIT' => strategy.commit
    end
  end
end
