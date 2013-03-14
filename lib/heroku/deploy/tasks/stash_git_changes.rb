module Heroku::Deploy::Task
  class StashGitChanges < Base
    include Heroku::Deploy::Shell

    def before_deploy
      output = git "status --untracked-files --short"

      unless output.empty?
        @stash_name = "heroku-deploy-#{Time.now.to_i}"
        task "Stashing your current changes" do
          git "stash save -u #{@stash_name}"
        end
      end
    end

    def rollback_before_deploy
      after_deploy
    end

    def after_deploy
      return unless @stash_name

      task "Applying back your local changes" do
        stashes       = git 'stash list'
        matched_stash = stashes.split("\n").find { |x| x.match @stash_name }
        label         = matched_stash.match(/^([^:]+)/)

        # Make sure there are no weird local changes (think db/schema.db changing
        # because we ran migrations locally, and column order changing because postgres
        # is crazy like that)
        git "clean -fd"
        git "stash apply #{label}"
        git "stash drop #{label}"
      end
    end
  end
end
