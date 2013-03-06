class GitLocal
  include Heroku::Deploy::Shell

  def commit_sha(options)
    git_show = shell %{git show --format=short #{options[:ref]}}
    commit_sha = git_show.match(/^commit\s(.+)$/) ? $1.chomp : nil
  end

  def current_branch
    ref = shell %{git symbolic-ref -q HEAD}
    ref.to_s.chomp.split("/").last
  end

  def checkout(ref)
    shell %{git checkout #{ref}}
  end

  def fetch
    shell %{git fetch}
  end

  def diff(options)
    shell %{git show --pretty="format:" #{options[:from]}..#{options[:to]} db/migrate}
  end

  def push_to(options)
    shell "git push #{options[:remote]} #{options[:ref]}:master", :exec => true
  end
end
