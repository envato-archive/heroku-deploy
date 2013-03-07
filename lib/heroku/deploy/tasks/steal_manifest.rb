module Heroku::Deploy::Task
  class StealManifest < Base
    def before_push
      manifest_url = "http://#{app.host}/assets/manifest.yml"
      asset_path = "public/assets"

      shell %{mkdir -p "#{asset_path}"}
      shell %{cd "#{asset_path}" && curl -O "#{manifest_url}"}
    end
  end
end
