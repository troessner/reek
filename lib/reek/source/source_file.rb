require 'reek/source/source_code'

module Reek
  module Source

    #
    # Represents a file of Ruby source, whose contents will be examined
    # for code smells.
    #
    class SourceFile < SourceCode

      def initialize(path)
        @path = path
        super(IO.readlines(@path).join, @path)
      end

      def relevant_config_files
        path = File.expand_path(File.dirname(@path))
        all_config_files(path)
      end

      private

      def all_config_files(path)
        return [] unless File.exist?(path)
        parent = File.dirname(path)
        return [] if path == parent
        all_config_files(parent) + Dir["#{path}/*.reek", "#{path}/.reek"]
      end
    end
  end
end
