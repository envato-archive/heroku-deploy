require "heroku/deploy/ui/colors"
require "heroku/deploy/ui/spinner"

module Heroku::Deploy
  module UI
    include Colors
    extend Colors

    PREFIX = colorize("--> ", :yellow)

    def task(message, options = {})
      print "#{PREFIX}#{message}"
      return_value = nil

      if block_given?
        print "... "
        spinner = Heroku::Deploy::UI::Spinner.new
        spinner.start

        begin
          return_value = yield
        rescue => e
          spinner.stop
          print colorize(icon(:cross), :red) + "\n"
          raise e
        end

        spinner.stop
        print colorize(icon(:tick), :green)
      end

      print "\n"

      return_value
    end

    def finish(message)
      puts "#{PREFIX}#{colorize message, :green} #{emoji :smile}"
      exit 0
    end

    def warning(message)
      puts "#{PREFIX}#{colorize message, :red}"
    end

    def error(message)
      print_and_colorize message, :red
    end

    def fatal(message)
      error(message)
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

    def chop_sha(sha)
      if sha
        sha[0..7]
      else
        ""
      end
    end

    def print_and_colorize(message, color)
      puts colorize(message, color)
    end
  end
end
