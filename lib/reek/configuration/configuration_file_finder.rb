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
    # 2. Having a file ending with .reek either in your current working
    #    directory or in a parent directory
    # 3. Having a file ending with .reek in your HOME directory
    #
    # The order in which ConfigurationFileFinder tries to find such a
    # configuration file is exactly like above.
    module ConfigurationFileFinder
      TOO_MANY_CONFIGURATION_FILES_MESSAGE = <<-EOS.freeze

        Error: Found multiple configuration files %s
        while scanning directory %s.

        Reek supports only one configuration file. You have 2 options now:
        1) Remove all offending files.
        2) Be specific about which one you want to load via the -c switch.

      EOS

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
        # :reek:TooManyStatements: { max_statements: 7 }
        def load_from_file(path)
          return {} unless path

          begin
            yaml_documents = YAML.load_stream File.read(path)
          rescue => error
            raise ConfigFileException, "Invalid configuration file #{path}, error is #{error}"
          end

          unless yaml_documents.all? { |document| document.is_a? Hash }
            raise ConfigFileException, "Invalid configuration file \"#{path}\" -- Not a hash"
          end

          array_of_hashes_to_hash(yaml_documents)
        end

        private

        # Combines multiple hashes into a single hash.
        # If two hashes have the same key, the values are combined
        #
        # Example
        #   array_of_hashes_to_hash([{"exclude_path"=>["first_path"], "other" => 1}, {"exclude_path"=>["second_path"]}])
        #   => {"exclude_path"=>["first_path", "second_path"]], "other"=>1}
        #
        # :reek:NestedIterators: { max_allowed_nesting: 2 }
        # :reek:TooManyStatements: { max_statements: 8 }
        def array_of_hashes_to_hash(array_of_hashes)
          hash_with_array_default = Hash.new { |hash, key| hash[key] = [] }

          combined_hash = array_of_hashes.each_with_object(hash_with_array_default) do |hash, acc|
            hash.each { |key, value| acc[key] << value }
          end

          combined_hash.each do |key, value|
            value.flatten!
            combined_hash[key] = value.first if value.count == 1
          end
        end

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
          offensive_files = found.map { |file| "'#{file.basename}'" }.join(', ')
          warn format(TOO_MANY_CONFIGURATION_FILES_MESSAGE, offensive_files, directory)
          exit 1
        end
      end
    end
  end
end
