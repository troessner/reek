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
    end
  end
end
