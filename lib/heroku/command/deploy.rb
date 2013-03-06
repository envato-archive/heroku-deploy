require 'heroku/command/run'

class Heroku::Command::Deploy < Heroku::Command::Run
  # deploy
  #
  # deploy your code
  def deploy
    p 'test'
  end
  alias_command 'deploy', 'deploy:deploy'
end
