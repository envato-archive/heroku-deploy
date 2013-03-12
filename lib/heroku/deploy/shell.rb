module Heroku::Deploy
  module Shell
    class CommandFailed < StandardError; end

    include UI

    def git(cmd, options = {})
      shell "git #{cmd}", options
    end

    def shell(cmd, options = {})
      original_cmd = cmd

      # Ensure all output is written to the same place
      cmd = "#{cmd} 2>&1"

      if env = options[:env]
        exports = env.keys.map { |key| "#{key}=#{env[key].inspect}" }
        cmd = "#{exports.join " "} #{cmd}"
      end

      puts "$  #{cmd}" if ENV['DEBUG']

      if options[:exec]
        success = system cmd

        raise CommandFailed.new("`#{original_cmd}` failed") unless success
      else
        output      = `#{cmd}`
        exit_status = $?.to_i

        if exit_status.to_i > 0
          raise CommandFailed.new("`#{original_cmd}` return an exit status of #{exit_status}\n\n#{output}")
        end

        # Ensure the string is valid utf8
        cleaned_output = output.to_s.chomp.force_encoding("ISO-8859-1").encode("utf-8", :replace => nil)

        puts claned_output if ENV['DEBUG']

        cleaned_output
      end
    end
  end
end
