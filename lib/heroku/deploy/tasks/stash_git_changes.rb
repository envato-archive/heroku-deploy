module Heroku::Deploy::Task
  class StashGitChanges < Base
    include Heroku::Deploy::Shell

    def before_push
      @requires_stashing = false

      task "Checking to see if you have any local changes that need stashing" do
        output = git "status --untracked-files --short"
        if !output.empty?
          @requires_stashing = true
        end
      end

      if @requires_stashing
        @name = "heroku-deploy-#{Time.now.to_i}"
        task "Stashing your current git changes" do
          git "stash save -u #{@name}"
        end
      end
    end

    def rollback_before_push
      after_push
    end

    def after_push
      return unless @requires_stashing

      task "Applying back your local changes" do
        stashes       = git 'stash list'
        matched_stash = stashes.split("\n").find { |x| x.match @name }
        label         = matched_stash.match(/^([^:]+)/)

        git "stash apply #{label}"
        git "stash drop #{label}"
      end
    end
  end
end
