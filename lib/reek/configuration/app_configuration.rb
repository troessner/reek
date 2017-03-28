# frozen_string_literal: true

require 'pathname'
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
      EXCLUDE_PATHS_KEY = 'exclude_paths'.freeze

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
        new
      end

      # Returns the directive for a given directory.
      #
      # @param source_via [String] - the source of the code inspected
      #
      # @return [Hash] the directory directive for the source with the default directive
      #                reverse-merged into it.
      def directive_for(source_via)
        hit = directory_directives.directive_for(source_via)
        hit ? default_directive.merge(hit) : default_directive
      end

      def path_excluded?(path)
        excluded_paths.map(&:expand_path).include?(path.expand_path)
      end

      def load_values(configuration_hash)
        configuration_hash.each do |key, value|
          if key == EXCLUDE_PATHS_KEY
            excluded_paths.add value
          elsif smell_type?(key)
            default_directive.add key, value
          else
            directory_directives.add key, value
          end
        end
      end

      private

      attr_writer :directory_directives, :default_directive, :excluded_paths

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
        configuration_hash = ConfigurationFileFinder.find_and_load(path: path)

        load_values(configuration_hash)
      end
    end
  end
end
