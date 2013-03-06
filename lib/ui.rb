module UI
  def finish(message)
    ok(message)
    exit 0
  end

  def error(message)
    puts "\033[31m#{message}\033[0m"
    exit 1
  end

  def info(message)
    puts "\033[36m#{message}\033[0m"
  end

  def ok(message)
    puts "\033[32m#{message}\033[0m"
  end
end
