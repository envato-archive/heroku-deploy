module Heroku::Deploy::Task
  class PrepareProductionBranch < Base
    include Heroku::Deploy::Shell

    def before_push
      @previous_branch = git "rev-parse --abbrev-ref HEAD"

      task "Fetching from #{colorize "origin", :cyan}" do
        git "fetch origin"
      end

      task "Switching to #{colorize strategy.branch, :cyan}" do
        branches = git "branch"

        if branches.match strategy.branch
          git "checkout #{strategy.branch}"
        else
          git "checkout -b #{strategy.branch}"
        end
      end

      task "Merging #{colorize @previous_branch, :cyan} into #{colorize strategy.branch, :cyan}" do
        git "merge #{strategy.commit}"
      end
    end

    def after_push
      task "Pushing local #{colorize strategy.branch, :cyan} to #{colorize "origin", :cyan}" do
        git "push -u origin #{strategy.branch}"
      end

      switch_back_to_old_branch
    end

    def rollback_before_push
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
