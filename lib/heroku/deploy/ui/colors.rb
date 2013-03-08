module Heroku::Deploy
  module UI
    module Colors
      COLORS = {
        :red     => 31,
        :green   => 32,
        :yellow  => 33,
        :magenta => 35,
        :cyan    => 36,
      }

      EMOJI = {
        :smile => "\u{1f60a}"
      }

      ICONS = {
        :tick => "\u{2714}"
      }

      def colorize(message, color)
        "\033[#{COLORS[color].to_s}m#{message}\033[0m"
      end

      def emoji(name)
        EMOJI[name]
      end

      def icon(name)
        ICONS[name]
      end
    end
  end
end
