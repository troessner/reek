require 'pathname'

module Reek
  module Configuration
    # Raised when config file is not properly readable.
    class ConfigFileException < StandardError; end
    #
    # ConfigurationFileFinder is responsible for finding Reek's configuration.
    #
    # There are 3 ways of passing `reek` a configuration file:
    # 1. Using the cli "-c" switch
    # 2. Having a file ending with .reek either in your current working
    #    directory or in a parent directory
    # 3. Having a file ending with .reek in your HOME directory
    #
    # The order in which ConfigurationFileFinder tries to find such a
    # configuration file is exactly like above.
    module ConfigurationFileFinder
      module_function

      def find_and_load(path: nil)
        load_from_file(find(path: path))
      end

      # :reek:ControlParameter
      def find(path: nil, current: Pathname.pwd, home: Pathname.new(Dir.home))
        path || find_by_dir(current) || find_in_dir(home)
      end

      def find_by_dir(start)
        start.ascend do |dir|
          found = find_in_dir(dir)
          return found if found
        end
      end

      def find_in_dir(dir)
        files = dir.children.select(&:file?).sort
        files.find { |file| file.to_s.end_with?('.reek') }
      end

      # :reek:TooManyStatements: { max_statements: 6 }
      def load_from_file(path)
        return {} unless path
        begin
          configuration = YAML.load_file(path) || {}
        rescue => error
          raise ConfigFileException, "Invalid configuration file #{path}, error is #{error}"
        end

        unless configuration.is_a? Hash
          raise ConfigFileException, "Invalid configuration file \"#{path}\" -- Not a hash"
        end
        configuration
      end
    end
  end
end
