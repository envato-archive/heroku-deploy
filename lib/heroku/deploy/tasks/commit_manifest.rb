module Heroku::Deploy::Task
  class CommitManifest < Base
    include Heroku::Deploy::Shell

    def before_push
      @previous_sha = calcuate_sha

      git 'add public/assets/manifest.yml'
      git 'commit -m "Manifest for deploy"'

      # Change which commit to deploy. This one includes a manifest
      strategy.commit = calcuate_sha
    end

    def rollback_before_push
      after_push
    end

    def after_push
      git %{reset --hard #{@previous_sha}}
    end

    private

    def calculate_sha
      git 'rev-parse --verify HEAD'
    end
  end
end
