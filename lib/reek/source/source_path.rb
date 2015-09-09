require 'private_attr/everywhere'
require 'find'
require 'pathname'

module Reek
  module Source
    #
    # Source file path in a filesystem.
    #
    class SourcePath
      attr_reader :pathname

      # Initialize with the pathname and configuration.
      #
      # pathname - a path as Pathname
      def initialize(pathname, configuration: Configuration::AppConfiguration.default)
        @configuration = configuration
        @pathname = pathname
        ensure_file
      end

      # Traverses all paths under current path, finds
      # all relevant Ruby files and returns them as a list.
      #
      # @return Enumerator - if no block given
      def relevant_children
        return enum_for(:relevant_children) unless block_given?
        pathname.find do |pathname|
          if (path = SourcePath.new(pathname, configuration: configuration)).relevant?
            yield path
          elsif path.ignored?
            Find.prune
          end
        end
      end

      # Checks is path is relevant
      #
      # Throws :prune if path is ignored
      #
      # @return Boolean
      def relevant?
        ruby_file? && !ignored?
      end

      def ignored?
        path_excluded? || hidden_directory?
      end

      private

      private_attr_reader :configuration

      def current_directory?
        [Pathname.new('.'), Pathname.new('./')].include?(pathname)
      end

      def path_excluded?
        configuration.path_excluded?(pathname)
      end

      def print_no_such_file_error
        $stderr.puts "Error: No such file - #{pathname}"
      end

      def hidden_directory?
        pathname.basename.to_s.start_with?('.') && !current_directory?
      end

      def ruby_file?
        pathname.extname == '.rb'
      end

      def ensure_file
        print_no_such_file_error unless pathname.exist?
      end
    end
  end
end
