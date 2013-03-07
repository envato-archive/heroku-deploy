module Heroku::Deploy::Task
  class PushCode < Base
    include Heroku::Deploy::Shell

    def perform
      commit = strategy.commit
      git_url = app.git_url

      task "Pushing commit #{colorize commit[0..7], :cyan}"
      git "push #{git_url} #{commit}:master --force -v", :exec => true

      # Make sure we store the original, because strategy.commit may have
      # changed from one of the tasks (manifest commit)
      app.put_config_vars 'DEPLOYED_COMMIT' => strategy.delta.to
    end
  end
end
