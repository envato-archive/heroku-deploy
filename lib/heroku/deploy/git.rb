class Git
  include Heroku::Deploy::Shell

  def sha_for_ref(ref)
    git_show = shell %{git show --format=short #{ref}}
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
    shell %{git show --pretty="format:" #{options[:from]}..#{options[:to]} #{options[:folder]}}
  end

  def push_to(options)
    shell "git push #{options[:remote]} #{options[:ref]}:master --force", :exec => true
  end
end
