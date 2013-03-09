module Heroku::Deploy::Task
  class PushCode < Base
    include Heroku::Deploy::Shell

    def deploy
      git_url = app.git_url

      task "Pushing #{colorize strategy.branch, :cyan} to #{colorize "#{git_url}:master", :cyan}"
      git "push #{git_url} #{strategy.branch}:master -v", :exec => true

      # Make sure we store the original, because strategy.commit may have
      # changed from one of the tasks (manifest commit)
      app.put_config_vars 'DEPLOYED_COMMIT' => strategy.delta.to
    end
  end
end
