require 'private_attr/everywhere'
require 'find'
require 'pathname'
require 'forwardable'

module Reek
  module Source
    #
    # Source file path in a filesystem.
    #
    class SourcePath
      extend Forwardable

      def_delegators :pathname, :read, :to_s

      # Initialize with the pathname and configuration.
      #
      # pathname - a path as Pathname
      def initialize(pathname, configuration: Configuration::AppConfiguration.default)
        @configuration = configuration
        @pathname = pathname.cleanpath
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
      # @return Boolean
      def relevant?
        ruby_file? && !ignored?
      end

      # Checks is path is ignored
      #
      # @return Boolean
      def ignored?
        path_excluded? || hidden_directory?
      end

      def ==(other)
        other.to_s == to_s
      end

      private

      private_attr_reader :configuration, :pathname

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
