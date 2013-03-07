module Heroku::Deploy
  module Shell
    include UI

    def git(cmd, options = {})
      shell "git #{cmd}", options
    end

    def shell(cmd, options = {})
      # Ensure all output is written to the same place
      cmd = "#{cmd} 2>&1"

      if env = options[:env]
        exports = env.keys.map { |key| "#{key}=#{env[key].inspect}" }
        cmd = "#{exports.join " "} #{cmd}"
      end

      puts "$  #{cmd}" if ENV['DEBUG']

      if options[:exec]
        system cmd
      else
        output = ""
        output = `#{cmd}`
        error output if $?.to_i > 0

        # Ensure the string is valid utf8
        output.to_s.chomp.force_encoding("ISO-8859-1").encode("utf-8", :replace => nil)
      end
    end
  end
end
