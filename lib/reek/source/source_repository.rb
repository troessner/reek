require_relative 'source_code'
require_relative 'source_locator'

module Reek
  module Source
    #
    # A collection of source code. If the collection is initialized with an array
    # it is assumed to be a list of file paths. Otherwise it is assumed to be a
    # single unit of Ruby source code.
    #
    class SourceRepository
      attr_reader :description

      def initialize(description, sources)
        @description = description
        @sources     = sources
      end

      # TODO: This method is a least partially broken.
      # Regardless of how you call reek, be it:
      #   reek lib/
      #   reek lib/file_one.rb lib/file_two.rb
      #   echo "def m; end" | reek
      # we *always* end up in the "when Source::SourceCode" branch.
      # So it seems like 80% of this method is never used.
      def self.parse(source)
        case source
        when Array
          new 'dir', Source::SourceLocator.new(source).sources
        when Source::SourceCode
          new source.description, [source]
        else
          src = Source::SourceCode.from source
          new src.description, [src]
        end
      end

      def each(&block)
        @sources.each(&block)
      end
    end
  end
end
