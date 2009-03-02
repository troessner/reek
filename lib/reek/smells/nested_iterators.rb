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
      # Any smells found are added to the +report+.
      #
      def examine_context(block, report)
        return false unless block.nested_block?
        report << SmellWarning.new(smell_name, block, 'is nested')
      end
    end
  end
end
