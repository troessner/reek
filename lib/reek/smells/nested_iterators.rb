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

      #
      # Checks whether the given +block+ is inside another.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine_context(block, report)
        return false unless block.nested_block?
        report << new(block)
      end

      def self.contexts      # :nodoc:
        [:iter]
      end

      def detailed_report
        "#{@context} is nested"
      end
    end

  end
end
