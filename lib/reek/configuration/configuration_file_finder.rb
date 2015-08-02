require 'pathname'

module Reek
  module Configuration
    class ConfigFileException < StandardError; end
    #
    # ConfigurationFileFinder is responsible for finding reek's configuration.
    #
    # There are 3 ways of passing `reek` a configuration file:
    # 1. Using the cli "-c" switch
    # 2. Having a file ending with .reek either in your current working
    #    directory or in a parent directory
    # 3. Having a file ending with .reek in your HOME directory
    #
    # The order in which ConfigurationFileFinder tries to find such a
    # configuration file is exactly like above.
    # @api private
    module ConfigurationFileFinder
      module_function

      def find_and_load(path: nil)
        load_from_file(find(path: path))
      end

      def find(path: nil, current: Pathname.pwd, home: Pathname.new(Dir.home))
        path || find_by_dir(current) || find_by_dir(home)
      end

      def find_by_dir(start)
        start.ascend do |dir|
          files = dir.children.select(&:file?).sort
          found = files.find { |file| file.to_s.end_with?('.reek') }
          return found if found
        end
      end

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
