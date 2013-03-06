module Heroku::Deploy
  module UI
    COLORS = %w(cyan yellow green magenta red)
    COLOR_CODES = {
      "red"     => 31,
      "green"   => 32,
      "yellow"  => 33,
      "magenta" => 35,
      "cyan"    => 36,
    }

    def finish(message)
      ok(message)
      exit 0
    end

    def error(message)
      print_and_colorize message, COLOR_CODES['red']
      exit 1
    end

    def info(message)
      print_and_colorize message, COLOR_CODES['cyan']
    end

    def ok(message)
      print_and_colorize message, COLOR_CODES['green']
    end

    def banner(message)
      print_and_colorize message, COLOR_CODES['magenta']
    end

    private

    def print_and_colorize(message, color)
      puts "\033[#{color}m#{message}\033[0m"
    end
  end
end
