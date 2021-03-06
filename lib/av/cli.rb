module Av
  class Cli
    attr_accessor :command
    
    def initialize(options)
      found = []
      found << 'avconv' if self.detect_command('avprobe')
      found << 'ffmpeg' if self.detect_command('ffmpeg')
      if found.empty?
        raise Av::UnableToDetect, "Unable to detect any supported library"
      else
        @command = Object.const_get('Av').const_get('Commands').const_get(found.first.capitalize).new(options)
      end
      ::Av.log("Found #{found.inspect}, using: #{found.first.capitalize}")
    end
    
    protected
      def method_missing name, *args, &block
        @command.send(name, *args, &block)
      end
  
      def detect_command(command)
        command = self.system_based_detect_command(command)
        result = ::Av.run(command)
        case result
          when /true/
            return true
          when /false/
            return false
        end
      end

      def system_based_detect_command(command)
        if Gem.win_platform?
          "#{command} -version  2>NUL && echo true || echo false"
        else
          "if command -v #{command} 2>/dev/null; then echo \"true\"; else echo \"false\"; fi"
        end
      end
  end
end
