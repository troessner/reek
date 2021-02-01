# frozen_string_literal: true

require 'find'
require 'pathname'

module Reek
  module Source
    #
    # Finds Ruby source files in a filesystem.
    #
    class SourceLocator
      # Initialize with the paths we want to search.
      #
      # paths - a list of paths as Strings
      def initialize(paths, configuration: Configuration::AppConfiguration.default, options: Reek::CLI::Options.new)
        @options = options
        @paths = paths.flat_map do |string|
          path = Pathname.new(string)
          current_directory?(path) ? path.entries : path
        end
        @configuration = configuration
      end

      # Traverses all paths we initialized the SourceLocator with, finds
      # all relevant Ruby files and returns them as a list.
      #
      # @return [Array<Pathname>] Ruby paths found
      def sources
        source_paths
      end

      private

      attr_reader :configuration, :paths, :options

      def source_paths
        paths.each_with_object([]) do |given_path, relevant_paths|
          if given_path.exist?
            relevant_paths.concat source_files_from_path(given_path)
          else
            print_no_such_file_error(given_path)
          end
        end
      end

      def source_files_from_path(given_path)
        relevant_paths = []
        given_path.find do |path|
          if path.directory?
            Find.prune if ignore_path?(path)
          elsif ruby_file?(path)
            relevant_paths << path unless ignore_file?(path)
          end
        end
        relevant_paths
      end

      def ignore_file?(path)
        if options.force_exclusion?
          path.ascend do |ascendant|
            break true if path_excluded?(ascendant)

            false
          end
        else
          path_excluded?(path)
        end
      end

      def path_excluded?(path)
        configuration.path_excluded?(path)
      end

      # @quality :reek:UtilityFunction
      def print_no_such_file_error(path)
        warn "Error: No such file - #{path}"
      end

      # @quality :reek:UtilityFunction
      def hidden_directory?(path)
        path.basename.to_s.start_with? '.'
      end

      def ignore_path?(path)
        path_excluded?(path) || hidden_directory?(path)
      end

      # @quality :reek:UtilityFunction
      def ruby_file?(path)
        path.extname == '.rb'
      end

      # @quality :reek:UtilityFunction
      def current_directory?(path)
        [Pathname.new('.'), Pathname.new('./')].include?(path)
      end
    end
  end
end
