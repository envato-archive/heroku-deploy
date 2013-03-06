require 'heroku/command/run'

class Heroku::Command::Deploy < Heroku::Command::Run
  # deploy
  #
  # deploy your code
  def deploy
    p 'test another'
  end
  alias_command 'deploy', 'deploy:deploy'
end
