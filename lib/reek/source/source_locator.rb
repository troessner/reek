require_relative '../source/source_path'

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
        @paths = paths.map do |string|
          SourcePath.new(Pathname.new(string), configuration: configuration)
        end
      end

      # Traverses all paths we initialized the SourceLocator with, finds
      # all relevant Ruby files and returns them as a list.
      #
      # @return [Array<Pathname>] - Ruby paths found
      def sources
        @paths.flat_map { |path| path.relevant_children.map(&:pathname) }
      end
    end
  end
end
