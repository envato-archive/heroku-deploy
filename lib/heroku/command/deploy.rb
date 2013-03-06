require 'heroku/command/run'

class Heroku::Command::Deploy < Heroku::Command::Run
  # deploy
  #
  # deploy your code
  def deploy
    Heroku::Deploy::Runner.deploy app, api
  end
  alias_command 'deploy', 'deploy:deploy'
end
