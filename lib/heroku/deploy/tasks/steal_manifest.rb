module Heroku::Deploy::Task
  class StealManifest < Base
    include Heroku::Deploy::Shell

    def before_push
      manifest_url = "http://#{app.host}/assets/manifest.yml"
      asset_path = "public/assets"

      task "Stealing manifest from #{colorize manifest_url, :cyan}" do
        shell %{mkdir -p "#{asset_path}"}
        shell %{cd "#{asset_path}" && curl -O "#{manifest_url}"}
      end
    end
  end
end
