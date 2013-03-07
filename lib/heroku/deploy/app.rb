module Heroku::Deploy
  class App
    attr_accessor :api, :name

    def initialize(api, name)
      @api  = api
      @name = name
    end

    def data
      @data ||= api.get_app(name).body
    end

    def env
      @env ||= unless @env
        vars = api.get_config_vars(name).body
        vars.reject { |key, value| key == 'PATH' || key == 'GEM_PATH' }
      end
    end
  end
end
