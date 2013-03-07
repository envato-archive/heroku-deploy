module Heroku::Deploy::Task
  class StashGitChanges < Base
    include Heroku::Deploy::Shell

    def before_push
      @stash = "heroku-deploy-#{Time.now.to_s}"

      git "stash -u #{@stash_name}"
    end

    def after_push
      stashes       = git 'stash list'
      matched_stash = stashes.split("\n").find { |x| x.match @stash }
      label         = matched_stash.match(/^([^:]+)/)

      git "stash apply #{label}"
      git "stash drop #{label}"
    end
  end
end
