require 'heroku/command/run'

class Heroku::Command::Deploy < Heroku::Command::Run
  # deploy
  #
  # deploy your code
  def deploy
    Heroku::Deploy::Deployer.deploy Heroku::Deploy::App.new(api, app)
  end
  alias_command 'deploy', 'deploy:deploy'
end
