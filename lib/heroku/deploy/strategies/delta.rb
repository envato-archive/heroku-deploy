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
      runner.tasks = [
        StashGitChanges.new(self),
        PrepareProductionBranch.new(self)
      ]

      if diff.has_asset_changes?
        runner.tasks << CompileAssets.new(self)
        runner.tasks << CommitAssets.new(self)
      end

      if diff.has_unsafe_migrations?
        runner.tasks << UnsafeMigration.new(self)
      elsif diff.has_migrations?
        runner.tasks << SafeMigration.new(self)
      end

      runner.tasks << PushCode.new(self)

      runner.perform_methods :before_deploy, :deploy, :after_deploy
    end
  end
end
