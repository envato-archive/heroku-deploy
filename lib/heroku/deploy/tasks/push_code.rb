module Heroku::Deploy::Task
  class PushCode < Base
    def git
      @git ||= Git.new
    end

    def perform
      git_url = app_data['git_url']

      git.push_to :remote => git_url, :ref => commit
      api.put_config_vars app_data['name'], { 'DEPLOYED_COMMIT' => commit }
    end
  end
end
