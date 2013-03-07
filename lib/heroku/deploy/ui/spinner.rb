module Heroku::Deploy
  module UI
    class Spinner
      include Colors

      def initialize
        @spinner = nil
        @chars = [ '|', '/', '-', '\\' ].map { |c| colorize(c, :yellow) }
      end

      def start
        @spinner = Thread.new do
          loop do
            print @chars[0]
            sleep(0.1)
            print "\b"
            @chars.push @chars.shift
          end
        end
      end

      # stops the spinner and backspaces over last displayed character
      def stop
        @spinner.kill
        print "\b"
      end
    end
  end
end
