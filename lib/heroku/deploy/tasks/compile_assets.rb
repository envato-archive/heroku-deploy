module Heroku::Deploy::Task
  class CompileAssets < Base
    def self.missing_assets?
      !File.exist?("public/assets/manifest.yml")
    end

    include Heroku::Deploy::Shell

    def before_deploy
      # TODO: Recomend that this is off?
      # initialize_on_precompile = shell %{bundle exec rails runner "puts Rails.application.config.assets.initialize_on_precompile"}

      env_vars = app.env.dup
      env_vars['RAILS_ENV'] = 'production'
      env_vars['RAILS_GROUPS'] = 'assets'
      env_vars.delete 'BUNDLE_WITHOUT'

      task "Precompiling assets"
      shell "bundle exec rake assets:precompile", :env => env_vars, :exec => true
    end

    def rollback_before_deploy
      task "Cleaning directory" do
        git "clean -fd"
      end
    end
  end
end
