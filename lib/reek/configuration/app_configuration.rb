require 'pathname'
require 'private_attr/everywhere'
require_relative './configuration_file_finder'
require_relative './configuration_validator'
require_relative './default_directive'
require_relative './directory_directives'
require_relative './excluded_paths'

module Reek
  module Configuration
    #
    # Reek's application configuration.
    #
    # @public
    class AppConfiguration
      include ConfigurationValidator
      EXCLUDE_PATHS_KEY = 'exclude_paths'
      private_attr_writer :directory_directives, :default_directive, :excluded_paths

      # Instantiate a configuration via given path.
      #
      # @param path [Pathname] the path to the config file
      #
      # @return [AppConfiguration]
      #
      # @public
      def self.from_path(path = nil)
        allocate.tap do |instance|
          instance.instance_eval { find_and_load(path: path) }
        end
      end

      # Instantiate a configuration by passing everything in.
      #
      # @deprecated This method will be removed in Reek 4.0.
      #
      # @param [Hash] map a hash with three possible keys representing
      # different types of directives.
      # @option map [Hash] :directory_directives Directory specific configuration
      #   for instance:
      #     { Pathname("spec/samples/three_clean_files/") =>
      #       { Reek::Smells::UtilityFunction => { "enabled" => false } } }
      # @option map [Hash] :default_directive Default configuration
      #   for instance:
      #     { Reek::Smells::IrresponsibleModule => { "enabled" => false } }
      # @option map [Array] :excluded_paths list of paths to exclude from analysis
      #   for instance:
      #     [ Pathname('spec/samples/two_smelly_files') ]
      #
      # @return [AppConfiguration]
      #
      # @public
      def self.from_map(map = {})
        allocate.tap do |instance|
          instance.instance_eval do
            load_values map.fetch(:directory_directives, {})
            load_values map.fetch(:default_directive, {})
            load_values EXCLUDE_PATHS_KEY => map.fetch(:excluded_paths, [])
          end
        end
      end

      # Instantiate a configuration by passing everything in.
      #
      # Loads the configuration from a hash of the form that is loaded from a
      # +.reek+ config file.
      # @param [Hash] hash The configuration hash to load.
      #
      # @return [AppConfiguration]
      #
      # @public
      def self.from_hash(hash = {})
        allocate.tap do |instance|
          instance.instance_eval do
            load_values hash
          end
        end
      end

      def self.default
        from_path nil
      end

      def self.new(*)
        raise NotImplementedError,
              'Calling `new` is not supported, please use one of the factory methods'
      end

      # Returns the directive for a given directory.
      #
      # @param source_via [String] - the source of the code inspected
      #
      # @return [Hash] the directory directive for the source or, if there is
      # none, the default directive
      def directive_for(source_via)
        directory_directives.directive_for(source_via) || default_directive
      end

      def path_excluded?(path)
        excluded_paths.include?(path)
      end

      private

      def directory_directives
        @directory_directives ||= {}.extend(DirectoryDirectives)
      end

      def default_directive
        @default_directive ||= {}.extend(DefaultDirective)
      end

      def excluded_paths
        @excluded_paths ||= [].extend(ExcludedPaths)
      end

      def find_and_load(path: nil)
        configuration_file = ConfigurationFileFinder.find_and_load(path: path)

        load_values(configuration_file)
      end

      def load_values(configuration_file)
        configuration_file.each do |key, value|
          case
          when key == EXCLUDE_PATHS_KEY
            excluded_paths.add value
          when smell_type?(key)
            default_directive.add key, value
          else
            directory_directives.add key, value
          end
        end
      end
    end
  end
end
