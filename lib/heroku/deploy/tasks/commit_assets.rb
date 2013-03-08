module Heroku::Deploy::Task
  class CommitManifest < Base
    include Heroku::Deploy::Shell

    def before_push
      @previous_sha = calculate_sha

      raise 'garr!'

      name = "manifest.yml"
      manifest = "public/assets/#{name}"
      error "#{manifest} could not be found" unless File.exist?(manifest)

      has_changes = false
      task "Checking to see if there are any #{colorize name, :cyan} changes" do
        changes = git %{status #{manifest} --porcelain}
        has_changes = !changes.empty?
      end

      if has_changes
        task "Commiting changed #{colorize name, :cyan} for deployment" do
          git %{add #{manifest}}
          git %{commit #{manifest} -m "Manifest for deploy"}
        end

        strategy.commit = calculate_sha
      end
    end

    def rollback_before_push
      after_push
    end

    def after_push
      git %{reset --hard #{@previous_sha}}
    end

    private

    def calculate_sha
      git 'rev-parse --verify HEAD'
    end
  end
end
