require 'reek/smells/smell_detector'
require 'reek/smell_warning'

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
        report << SmellWarning.new(self, block, 'is nested')
      end
    end
  end
end
