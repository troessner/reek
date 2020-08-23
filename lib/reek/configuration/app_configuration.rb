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

      # Instantiate a configuration via the given path.
      #
      # @param path [Pathname] the path to the config file.
      #
      # @return [AppConfiguration]
      #
      # @public
      def self.from_path(path)
        values = ConfigurationFileFinder.find_and_load(path: path)
        new(values: values)
      end

      # Instantiate a configuration via the default path.
      #
      # @return [AppConfiguration]
      #
      # @public
      def self.from_default_path
        values = ConfigurationFileFinder.find_and_load(path: nil)
        new(values: values)
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
      def self.from_hash(hash)
        new(values: hash)
      end

      def self.default
        new(values: {})
      end

      # Returns the directive for a given directory.
      #
      # @param source_via [String] the source of the code inspected
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

      def load_values(values)
        values.each do |key, value|
          case key
          when EXCLUDE_PATHS_KEY
            excluded_paths.add value
          when DIRECTORIES_KEY
            directory_directives.add value
          when DETECTORS_KEY
            default_directive.add value
          end
        end
      end

      def initialize(values: {})
        load_values(values)
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
    end
  end
end
