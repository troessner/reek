require 'find'
require 'pathname'

module Reek
  module Source
    #
    # Finds Ruby source files in a filesystem.
    #
    # @api private
    class SourceLocator
      # Initialize with the paths we want to search.
      #
      # paths - a list of paths as Strings
      def initialize(paths, configuration: Configuration::AppConfiguration.new)
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
        configuration.exclude_paths.include?(path)
      end

      def print_no_such_file_error(path)
        $stderr.puts "Error: No such file - #{path}"
      end

      def hidden_directory?(path)
        path.basename.to_s.start_with? '.'
      end

      def ignore_path?(path)
        path_excluded?(path) || hidden_directory?(path)
      end

      def ruby_file?(path)
        path.extname == '.rb'
      end

      def current_directory?(path)
        [Pathname.new('.'), Pathname.new('./')].include?(path)
      end
    end
  end
end
