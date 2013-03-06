module Heroku::Deploy
  class Strategy::DeployToHeroku
    include UI

    attr_accessor :git, :commit, :app_data, :api

    def initialize(commit, app_data, api)
      @api      = api
      @commit   = commit
      @app_data = app_data
    end

    def git
      @git ||= Git.new
    end

    def push_code
      git_url = app_data['git_url']

      git.push_to :remote => git_url, :ref => commit
      api.put_config_vars app_data['name'], { 'DEPLOYED_COMMIT' => commit }
    end

    def perform
      push_code
    end
  end
end
