class HerokuApp
  include Shell

  attr_accessor :git, :app_name

  def initialize(app_name)
    self.app_name = app_name
    self.git = GitRemote.new git_remote
  end

  def git_remote
    "git@heroku.com:#{app_name}.git"
  end

  def is_staging?
    app_name.match(/staging/)
  end

  def prepare_search_database!
    remote_database_shell %{rake db:search:prepare}, :exec => true
  end

  def migrate!
    remote_database_shell %{rake db:migrate}, :exec => true
  end

  private

  def remote_database_shell(cmd, options = {})
    rails_env    = config('RAILS_ENV')
    database_url = config('DATABASE_URL')

    heroku_shell %{DATABASE_URL=#{database_url} RAILS_ENV=#{rails_env} #{cmd}}, options
  end

  def heroku_shell(cmd, options={})
    output = shell "#{cmd} --app #{app_name}", options

    unless options[:exec]
      if output.match /Authentication failure/
        error "Arrgh! I couldnt perform this heroku command.\n#{output}"
      end
    end

    output
  end
end
