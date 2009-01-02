$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # A Nested Iterator occurs when a block contains another block.
    #
    # +NestedIterators+ reports failing methods only once.
    #
    class NestedIterators < SmellDetector

      def self.contexts      # :nodoc:
        [:iter]
      end

      #
      # Checks whether the given +block+ is inside another.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def examine_context(block, report)
        return false unless block.nested_block?
        report << NestedIteratorsReport.new(block)
      end
    end

    class NestedIteratorsReport < SmellReport

      def warning
        "is nested"
      end
    end
  end
end
