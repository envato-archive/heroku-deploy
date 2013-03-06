class BugsnagNotifier
  include Shell

  def self.notify(options)
    new.notify(options)
  end

  def notify(options)
    shell %{curl -d "apiKey=#{options[:api_key]}&releaseStage=#{options[:release_stage] || 'production'}" http://notify.bugsnag.com/deploy}
  end
end
