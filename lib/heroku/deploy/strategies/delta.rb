module Heroku::Deploy::Strategy
  class Delta < Base
    include Heroku::Deploy::Task

    def diff
      @diff ||= unless @diff
                  difference = "#{chop_sha deployed_commit}..#{chop_sha new_commit}"
                  task "Performing diff on #{colorize difference, :cyan}" do
                    Heroku::Deploy::Diff.diff deployed_commit, new_commit
                  end
                end
    end

    def perform
      strategy = self

      tasks = [
        StashGitChanges.new(self),
        PrepareProductionBranch.new(self)
      ]

      tasks << Proc.new do
        if strategy.diff.has_asset_changes?
          CompileAssets.new(strategy)
        end
      end

      tasks << Proc.new do
        if strategy.diff.has_asset_changes?
          CommitAssets.new(strategy)
        end
      end

      tasks << PushToOrigin.new(self)

      tasks << Proc.new do
        if strategy.diff.has_unsafe_migrations?
          UnsafeMigration.new(self)
        elsif strategy.diff.has_migrations?
          SafeMigration.new(self)
        end
      end

      tasks << PushToHeroku.new(self)

      runner.tasks = tasks
      runner.perform_methods :before_deploy, :deploy, :after_deploy
    end
  end
end
