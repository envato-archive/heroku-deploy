module Heroku::Deploy::Task
  class CompileAssets < Base
    include Heroku::Deploy::Shell

    def before_push
      # TODO: Recomend that this is off?
      # initialize_on_precompile = shell %{bundle exec rails runner "puts Rails.application.config.assets.initialize_on_precompile"}

      task "Precompiling assets"
      shell "bundle exec rake assets:precompile:primary", :env => app.env, :exec => true
    end
  end
end
