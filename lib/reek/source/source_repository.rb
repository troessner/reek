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

      # Parses the given source and tries to convert that to Source::SourceCode.
      #
      # @param source [Array|Source::SourceCode|something else] the source
      # @return [Array] the source converted into a list of Source::SourceCode objects
      def self.parse(source)
        case source
        when Array
          new 'dir', Source::SourceLocator.new(source).sources
        when Source::SourceCode
          new source.description, [source]
        else
          source_code = Source::SourceCode.from source
          new source_code.description, [source_code]
        end
      end

      def each(&block)
        @sources.each(&block)
      end
    end
  end
end
