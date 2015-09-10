require 'private_attr/everywhere'
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
      def initialize(paths, configuration: Configuration::AppConfiguration.default)
        @paths = paths.flat_map do |string|
          path = Pathname.new(string)
          current_directory?(path) ? path.entries : path
        end
        @configuration = configuration
      end

      # Traverses all paths we initialized the SourceLocator with, finds
      # all relevant Ruby files and returns them as a list.
      #
      # @return [Array<Pathname>] - Ruby paths found
      def sources
        source_paths
      end

      private

      private_attr_reader :configuration, :paths

      # :reek:TooManyStatements: { max_statements: 6 }
      # :reek:NestedIterators: { max_allowed_nesting: 2 }
      def source_paths
        paths.each_with_object([]) do |given_path, relevant_paths|
          print_no_such_file_error(given_path) && next unless given_path.exist?
          given_path.find do |path|
            if path.directory?
              ignore_path?(path) ? Find.prune : next
            else
              relevant_paths << path if ruby_file?(path)
            end
          end
        end
      end

      def path_excluded?(path)
        configuration.path_excluded?(path)
      end

      # :reek:UtilityFunction
      def print_no_such_file_error(path)
        $stderr.puts "Error: No such file - #{path}"
      end

      # :reek:UtilityFunction
      def hidden_directory?(path)
        path.basename.to_s.start_with? '.'
      end

      def ignore_path?(path)
        path_excluded?(path) || hidden_directory?(path)
      end

      # :reek:UtilityFunction
      def ruby_file?(path)
        path.extname == '.rb'
      end

      # :reek:UtilityFunction
      def current_directory?(path)
        [Pathname.new('.'), Pathname.new('./')].include?(path)
      end
    end
  end
end
