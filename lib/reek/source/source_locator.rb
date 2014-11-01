require 'reek/source/core_extras'

module Reek
  module Source
    #
    # Finds Ruby source files in a filesystem.
    #
    class SourceLocator
      def initialize(paths)
        @paths = paths.map { |path| path.chomp('/') }
      end

      def all_sources
        valid_paths.map { |path| File.new(path).to_reek_source }
      end

      private

      def all_ruby_source_files(paths)
        paths.map do |path|
          if test 'd', path
            all_ruby_source_files(Dir["#{path}/**/*.rb"])
          else
            path
          end
        end.flatten.sort
      end

      def valid_paths
        all_ruby_source_files(@paths).select do |path|
          if test 'f', path
            true
          else
            $stderr.puts "Error: No such file - #{path}"
            false
          end
        end
      end
    end
  end
end
