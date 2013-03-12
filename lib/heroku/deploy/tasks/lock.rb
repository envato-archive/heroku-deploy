module Heroku::Deploy::Task
  class Lock < Base
    include Heroku::Deploy::Shell

    def before_deploy
      if app.env['HEROKU_DEPLOY_LOCK'] == 'true'
        warning "Someone else is currently deploying."
        exit 0
      end

      task "Locking deploys for #{colorize app.name, :cyan}" do
        app.put_config_vars 'HEROKU_DEPLOY_LOCK' => true
      end
    end

    def rollback_before_deploy
      after_deploy
    end

    def after_deploy
      task "Locking deploys for #{colorize app.name, :cyan}" do
        app.put_config_vars 'HEROKU_DEPLOY_LOCK' => false
      end
    end
  end
end
