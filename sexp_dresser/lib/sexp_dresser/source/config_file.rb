require 'yaml'

module SexpDresser
  module Source

    #
    # A file called <something>.sexp_dresser containing configuration settings for
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
