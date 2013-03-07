module Heroku::Deploy::Task
  class CompileAssets < Base
    include Heroku::Deploy::Shell

    ENV_VARIABLES = [
      "AWS_ACCESS_KEY_ID",
      "AWS_SECRET_ACCESS_KEY",
      "FOG_DIRECTORY",
      "FOG_PROVIDER",
      "FOG_REGION",
      "ASSET_SYNC_GZIP_COMPRESSION",
      "ASSET_SYNC_MANIFEST",
      "ASSET_SYNC_EXISTING_REMOTE_FILES",
      "RACKSPACE_USERNAME",
      "RACKSPACE_API_KEY",
      "GOOGLE_STORAGE_ACCESS_KEY_ID",
      "GOOGLE_STORAGE_SECRET_ACCESS_KEY"
    ]

    def before_push
      env_variables = ENV_VARIABLES.map do |key|
        if runner.env.has_key?(key)
          "#{key}=#{runner.env[key].inspect}"
        end
      end.compact

      env_variables << "RAILS_ENV=development"

      task "Precompiling assets" do
        shell "#{env_variables.join(" ")} bundle exec rake assets:precompile"
      end
    end
  end
end
