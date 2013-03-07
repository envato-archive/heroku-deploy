module Heroku::Deploy::Task
  class CommitManifest < Base
    include Heroku::Deploy::Shell

    def before_push
      git 'add public/assets/manifest.yml'
      git 'commit -m "Manifest for deploy"'

      strategy.commit = git 'rev-parse --verify HEAD'
    end
  end
end
