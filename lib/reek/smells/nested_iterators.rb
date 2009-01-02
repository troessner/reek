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

      #
      # Checks whether the given +block+ is inside another.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine_context(block, report)
        return false unless block.nested_block?
        report << NestedIteratorsReport.new(block)
      end

      def self.contexts      # :nodoc:
        [:iter]
      end

      def detailed_report
        "#{@context} is nested"
      end
    end

    class NestedIteratorsReport < SmellReport

      def detailed_report
        "#{@context} is nested"
      end
    end
  end
end
