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
      tasks = [
        StashGitChanges.new(self),
        PrepareProductionBranch.new(self)
      ]

      if diff.has_asset_changes? || CompileAssets.missing_assets?
        tasks << CompileAssets.new(self)
        tasks << CommitAssets.new(self)
      end

      if diff.has_unsafe_migrations?
        tasks << UnsafeMigration.new(self)
      elsif diff.has_migrations?
        tasks << SafeMigration.new(self)
      end

      tasks << PushCode.new(self)

      runner.tasks = tasks
      runner.perform_methods :before_deploy, :deploy, :after_deploy
    end
  end
end
