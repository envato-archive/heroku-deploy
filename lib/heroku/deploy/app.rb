module Heroku::Deploy
  class App
    attr_accessor :api, :name

    def initialize(api, name)
      @api  = api
      @name = name
    end

    def host
      data['domain_name']['domain']
    end

    def git_url
      data['git_url']
    end

    def env
      @env ||= unless @env
        vars = api.get_config_vars(name).body
        vars.reject { |key, value| key == 'PATH' || key == 'GEM_PATH' }
      end
    end

    def put_config_vars(vars)
      api.put_config_vars name, vars
    end

    def feature_enabled?(feature)
      all_features = api.get_features(name).body

      found_feature = all_features.find { |f| f['name'].to_s == feature.to_s }
      raise "Could not find feature `#{feature}`" unless found_feature

      found_feature['enabled']
    end

    def disable_maintenance
      post_app_maintenance '0'
    end

    def enable_maintenance
      post_app_maintenance '1'
    end

    def enable_feature(feature)
      api.post_feature feature, name
    end

    def disable_feature(feature)
      api.delete_feature feature, name
    end

    private

    def post_app_maintenance(action)
      api.post_app_maintenance name, action
    end

    def data
      @data ||= api.get_app(name).body
    end
  end
end
