$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    #
    # A Nested Iterator occurs when a block contains another block.
    #
    # +NestedIterators+ reports failing methods only once.
    #
    class NestedIterators < Smell
      def recognise?(already_in_iter)
        already_in_iter && @context
      end

      def detailed_report
        "#{@context} has nested iterators"
      end
    end

  end
end
