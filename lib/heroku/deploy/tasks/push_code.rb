module Heroku::Deploy::Task
  class PushCode < Base
    include Heroku::Deploy::Shell

    def perform
      commit = strategy.commit
      git_url = app.git_url

      git "push #{git_url} #{commit}:master --force -v", :exec => true

      app.put_config_vars app.name, { 'DEPLOYED_COMMIT' => commit }
    end
  end
end
