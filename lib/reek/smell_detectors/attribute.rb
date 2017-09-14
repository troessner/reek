# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # A class that publishes a getter or setter for an instance variable
    # invites client classes to become too intimate with its inner workings,
    # and in particular with its representation of state.
    #
    # This detector raises a warning for every public +attr_writer+,
    # +attr_accessor+, and +attr+ with the writable flag set to +true+.
    #
    # See {file:docs/Attribute.md} for details.
    #
    # TODO: Catch attributes declared "by hand"
    class Attribute < BaseDetector
      def self.contexts # :nodoc:
        [:sym]
      end

      #
      # Checks whether the given class declares any attributes.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        attributes_in_context.map do |_attribute, line|
          smell_warning(
            context: context,
            lines: [line],
            message: 'is a writable attribute')
        end
      end

      private

      def attributes_in_context
        if context.visibility == :public
          call_node = expression
          [[call_node.name, call_node.line]]
        else
          []
        end
      end
    end
  end
end
