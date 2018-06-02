# frozen_string_literal: true

require 'pathname'
require 'yaml'
require_relative './configuration_validator'
require_relative '../errors/config_file_exception'
require_relative './schema_validator'

module Reek
  module Configuration
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
      include ConfigurationValidator
      TOO_MANY_CONFIGURATION_FILES_MESSAGE = <<-MESSAGE.freeze

        Error: Found multiple configuration files %<files>s
        while scanning directory %<directory>s.

        Reek supports only one configuration file. You have 2 options now:
        1) Remove all offending files.
        2) Be specific about which one you want to load via the -c switch.

      MESSAGE

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
            raise Errors::ConfigFileException, "Invalid configuration file #{path}, error is #{error}"
          end
          SchemaValidator.validate configuration
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
        # Raises an exception if we find more than one.
        #
        # @return [File|nil]
        #
        # :reek:FeatureEnvy
        def find_in_dir(dir)
          found = dir.children.select { |item| item.file? && item.to_s.end_with?('.reek') }.sort
          if found.size > 1
            escalate_too_many_configuration_files found, dir
          else
            found.first
          end
        end

        #
        # Writes a proper warning message to STDERR and then exits the program.
        #
        # @return [undefined]
        #
        def escalate_too_many_configuration_files(found, directory)
          # Follow up TODO: Shouldn't this rather raise a ConfigFileException?
          offensive_files = found.map { |file| "'#{file.basename}'" }.join(', ')
          warn format(TOO_MANY_CONFIGURATION_FILES_MESSAGE, files: offensive_files, directory: directory)
          exit 1
        end
      end
    end
  end
end
