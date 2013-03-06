module Heroku::Deploy
  module Shell
    include UI

    def shell(cmd, options = {})
      puts "$  #{cmd}" if ENV['DEBUG']
      cmd = "#{cmd} 2>&1" # Ensure all output is written to the same place
      if options[:exec]
        system cmd
      else
        output = ""
        output = `#{cmd}`
        error output if $?.to_i > 0

        # Ensure the string is valid utf8
        output.to_s.chomp.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      end
    end
  end
end
