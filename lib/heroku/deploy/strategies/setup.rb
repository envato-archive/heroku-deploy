module Heroku::Deploy::Strategy
  class Setup < Base
    include Heroku::Deploy::Task

    def perform
      task "This looks like a first time deploy to Heroku"

      runner.tasks = [
        StashGitChanges.new(self),
        PrepareProductionBranch.new(self),
        CompileAssets.new(self),
        CommitAssets.new(self),
        UnsafeMigration.new(self),
        PushCode.new(self)
      ]

      runner.perform_methods :before_deploy, :deploy, :after_deploy
    end
  end
end
