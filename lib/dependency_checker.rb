class DependencyChecker
  include Shell

  def self.check!
    new.check!
  end

  def initialize
    @dependencies = { "git" => "git", "heroku" => "heroku-toolbelt" }
  end

  def check!
    @dependencies.each do |bin, install|
      shell "#{bin} --version"
      error "Need #{bin} installed. Try `brew install #{install}`" if $?.to_i > 0
    end
  end
end
