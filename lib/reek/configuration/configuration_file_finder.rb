# frozen_string_literal: true

require 'pathname'
require_relative './configuration_converter'
require_relative './schema_validator'
require_relative '../errors/config_file_error'

module Reek
  module Configuration
    #
    # ConfigurationFileFinder is responsible for finding Reek's configuration.
    #
    # There are 3 ways of passing `reek` a configuration file:
    # 1. Using the cli "-c" switch
    # 2. Having a file .reek.yml either in your current working
    #    directory or in a parent directory
    # 3. Having a file .reek.yml in your HOME directory
    #
    # The order in which ConfigurationFileFinder tries to find such a
    # configuration file is exactly like above.
    module ConfigurationFileFinder
      DEFAULT_FILE_NAME = '.reek.yml'

      class << self
        include ConfigurationValidator
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
        # @quality :reek:ControlParameter
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
        # @quality :reek:TooManyStatements { max_statements: 6 }
        def load_from_file(path)
          return {} unless path

          begin
            configuration = YAML.load_file(path) || {}
          rescue StandardError => error
            raise Errors::ConfigFileError, "Invalid configuration file #{path}, error is #{error}"
          end

          SchemaValidator.new(configuration).validate
          ConfigurationConverter.new(configuration).convert
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
        # @quality :reek:FeatureEnvy
        def find_in_dir(dir)
          dir.children.detect { |item| item.file? && item.basename.to_s == DEFAULT_FILE_NAME }
        end
      end
    end
  end
end
