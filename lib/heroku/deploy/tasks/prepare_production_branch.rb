module Heroku::Deploy::Task
  class PrepareProductionBranch < Base
    include Heroku::Deploy::Shell

    def before_deploy
      @previous_branch = git "rev-parse --abbrev-ref HEAD"

      # If HEAD is returned, it means we're on a random commit, instead
      # of a branch.
      if @previous_branch == "HEAD"
        @previous_branch = git "rev-parse --verify HEAD"
      end

      # Always fetch first. The repo may have already been created.
      # Also, unshallow the repo with the crazy --depth thing. See
      # http://permalink.gmane.org/gmane.comp.version-control.git/213186
      task "Fetching from #{colorize "origin", :cyan}"
      shell "(test -e .git/shallow) && rm .git/shallow" rescue CommandFailed # Command failed is raised if the file doesn't exist.
      git "fetch origin --depth=2147483647 -v", :exec => true

      task "Switching to #{colorize strategy.branch, :cyan}" do
        local_branches = git "branch"

        if local_branches.match /#{strategy.branch}$/
          git "checkout #{strategy.branch}"
        else
          git "checkout -b #{strategy.branch}"
        end

        # reset to whats on origin if the branch exists there already
        remote_branches = git "branch -a"

        if remote_branches.match /origin\/#{strategy.branch}$/
          git "reset origin/#{strategy.branch} --hard"
        end
      end

      task "Merging your current branch #{colorize @previous_branch, :cyan} into #{colorize strategy.branch, :cyan}" do
        git "merge #{strategy.new_commit}"
      end
    end

    def after_deploy
      switch_back_to_old_branch
    end

    def rollback_before_deploy
      switch_back_to_old_branch
    end

    private

    def switch_back_to_old_branch
      task "Switching back to #{colorize @previous_branch, :cyan}" do
        git "checkout #{@previous_branch}"
      end
    end
  end
end
