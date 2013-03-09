module Heroku::Deploy::Task
  class CommitAssets < Base
    include Heroku::Deploy::Shell

    def before_push
      @previous_sha = calculate_sha

      assets_folder = "public/assets"

      has_changes = false
      task "Checking to see if there are any changes in #{colorize assets_folder, :cyan}" do
        changes = git %{status #{assets_folder} --porcelain}
        has_changes = !changes.empty?
      end

      if has_changes
        task "Commiting changed #{colorize assets_folder, :cyan} for deployment" do
          git %{add #{assets_folder}}
          git %{commit #{assets_folder} -m "[heroku-deploy] Compiled assets for deployment"}
        end
      end
    end

    def rollback_before_push
      git %{reset --hard #{@previous_sha}}
    end

    private

    def calculate_sha
      git 'rev-parse --verify HEAD'
    end
  end
end
