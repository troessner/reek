require 'find'

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
      def initialize(paths)
        @paths = paths.map { |path| path.chomp('/') }
      end

      # Traverses all paths we initialized the SourceLocator with, finds
      # all relevant ruby files and returns them as a list.
      #
      # @return [Array<File>] - Ruby files found
      def sources
        source_paths.map { |pathname| File.new(pathname) }
      end

      private

      def source_paths
        relevant_paths = []
        @paths.map do |given_path|
          print_no_such_file_error(given_path) && next unless path_exists?(given_path)
          Find.find(given_path) do |path|
            pathname = Pathname.new(path)
            if pathname.directory?
              ignore_path?(pathname) ? Find.prune : next
            else
              relevant_paths << pathname if ruby_file?(pathname)
            end
          end
        end
        relevant_paths.flatten.sort
      end

      def path_excluded?(pathname)
        Configuration::AppConfiguration.exclude_paths.include? pathname.to_s
      end

      def path_exists?(path)
        Pathname.new(path).exist?
      end

      def print_no_such_file_error(path)
        $stderr.puts "Error: No such file - #{path}"
      end

      def hidden_directory?(pathname)
        pathname.basename.to_s.start_with? '.'
      end

      def ignore_path?(pathname)
        path_excluded?(pathname) || hidden_directory?(pathname)
      end

      def ruby_file?(pathname)
        pathname.to_s.end_with?('.rb')
      end
    end
  end
end
