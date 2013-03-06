class GitRemote
  include Shell

  attr_reader :repo

  def initialize(repo)
    @repo = repo
  end

  def latest_commit
    ls_remote = shell %{git ls-remote #{repo}}
    ls_remote.match(/^(.+)\s+HEAD$/) ? $1.chomp.strip : nil
  end
end
