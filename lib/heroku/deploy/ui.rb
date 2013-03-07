require "heroku/deploy/ui/colors"
require "heroku/deploy/ui/spinner"

module Heroku::Deploy
  module UI
    include Colors

    PREFIX = "--> "

    def task(message, &block)
      print "#{PREFIX}#{message}...."
      if block_given?
        spinner = Heroku::Deploy::UI::Spinner.new
        spinner.start
        yield
        spinner.stop
      end
      print colorize("✓\n", :green)
    end

    def finish(message)
      puts "#{colorize (PREFIX + message), :green} #{emoji :smile}"
      exit 0
    end

    def error(message)
      print_and_colorize message, :red
      exit 1
    end

    def info(message)
      print_and_colorize message, :cyan
    end

    def ok(message)
      print_and_colorize message, :green
    end

    def banner(message)
      print_and_colorize message, :magenta
    end

    private

    def print_and_colorize(message, color)
      puts colorize(message, color)
    end
  end
end
