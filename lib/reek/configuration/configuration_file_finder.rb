# frozen_string_literal: true

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
    # 2. Having a file ending with .reek.yml either in your current working
    #    directory or in a parent directory
    # 3. Having a file ending with .reek.yml in your HOME directory
    #
    # The order in which ConfigurationFileFinder tries to find such a
    # configuration file is exactly like above.
    module ConfigurationFileFinder
      DEFAULT_FILE_NAME = '.reek.yml'.freeze

      class << self
        #
        # Finds and loads a configuration file from a given path.
        #
        # @return [Hash]
        #
        def find_and_load(path: nil)
          load_from_file(find(path: path))
        end

        #
        # Tries to find a configuration file via:
        #   * given path (e.g. via cli switch)
        #   * ascending down from the current directory
        #   * looking into the home directory
        #
        # @return [File|nil]
        #
        # :reek:ControlParameter
        def find(path: nil, current: Pathname.pwd, home: Pathname.new(Dir.home))
          path || find_by_dir(current) || find_in_dir(home)
        end

        #
        # Loads a configuration file from a given path.
        # Raises on invalid data.
        #
        # @param path [String]
        # @return [Hash]
        #
        # :reek:TooManyStatements: { max_statements: 6 }
        def load_from_file(path)
          return {} unless path
          begin
            configuration = YAML.load_file(path) || {}
          rescue StandardError => error
            raise ConfigFileException, "Invalid configuration file #{path}, error is #{error}"
          end

          unless configuration.is_a? Hash
            raise ConfigFileException, "Invalid configuration file \"#{path}\" -- Not a hash"
          end
          configuration
        end

        private

        #
        # Recursively traverse directories down to find a configuration file.
        #
        # @return [File|nil]
        #
        def find_by_dir(start)
          start.ascend do |dir|
            file = find_in_dir(dir)
            return file if file
          end
        end

        #
        # Checks a given directory for a configuration file and returns it.
        #
        # @return [File|nil]
        #
        # :reek:FeatureEnvy
        def find_in_dir(dir)
          dir.children.detect { |item| item.file? && item.to_s.end_with?(DEFAULT_FILE_NAME) }
        end
      end
    end
  end
end
