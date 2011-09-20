require 'yaml'

module Reek
  module Source

    #
    # A file called <something>.reek containing configuration settings for
    # any or all of the smell detectors.
    #
    class ConfigFile
      @@bad_config_files = []

      #
      # Load the YAML config file from the supplied +file_path+.
      #
      def initialize(file_path)
        @file_path = file_path
        @hash = load
      end

      #
      # Configure the given sniffer using the contents of the config file.
      #
      def configure(sniffer)
        @hash.each do |klass_name, config|
          klass = find_class(klass_name)
          sniffer.configure(klass, config) if klass
        end
      end

      #
      # Find the class with this name if it exsits.
      # If not, report the problem and return +nil+.
      #
      def find_class(name)
        begin
          klass = Reek::Smells.const_get(name)
        rescue
          klass = nil
        end
        problem("\"#{name}\" is not a code smell") unless klass
        klass
      end

      #
      # Load the file path with which this was initialized,
      # unless it is already known to be a bad configuration file.
      # If it won't load, then it is considered a bad file.
      #
      def load
        unless @@bad_config_files.include?(@file_path)
          begin
            result = YAML.load_file(@file_path) || {}
            if Hash === result
              return result
            else
              @@bad_config_files << @file_path                            # poop
              problem('Not a hash')
            end
          rescue Exception => err
            @@bad_config_files << @file_path                              # poop
            problem(err.to_s)
          end
        end
        return {}
      end

      #
      # Report invalid configuration file to standard
      # Error.
      #
      def problem(reason)
        $stderr.puts "Error: Invalid configuration file \"#{File.basename(@file_path)}\" -- #{reason}"
        # SMELL: Duplication of 'Error:'
      end
    end
  end
end
