module Heroku::Deploy
  module UI
    class Spinner
      include Colors

      def initialize
        @spinner = nil
        @count = 0
        @chars = [ '|', '/', '-', '\\' ].map { |c| colorize(c, :yellow) }
      end

      def start
        @spinner = Thread.new do
          loop do
            print @chars[0]
            @count += 1
            sleep(0.1)
            print "\b"
            @chars.push @chars.shift
          end
        end
      end

      # stops the spinner and backspaces over last displayed character
      def stop
        @spinner.kill
        if @count > 0
          print "\b"
        end
      end
    end
  end
end
