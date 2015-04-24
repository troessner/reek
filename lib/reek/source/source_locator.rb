module Reek
  module Source
    #
    # Finds Ruby source files in a filesystem.
    #
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
      # Returns a list of Source::SourceCode.
      def sources
        find_sources.map { |pathname| Source::SourceCode.from File.new(pathname) }
      end

      private

      def find_sources(paths = @paths)
        paths.map do |path|
          pathname = Pathname.new(path)
          if pathname.directory?
            find_sources(Dir["#{pathname}/**/*.rb"])
          else
            next pathname if pathname.file?
            $stderr.puts "Error: No such file - #{pathname}"
            nil
          end
        end.flatten.sort
      end
    end
  end
end
