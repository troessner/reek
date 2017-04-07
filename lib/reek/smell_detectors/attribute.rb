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
      def initialize(*args)
        super
      end

      def self.contexts # :nodoc:
        [:sym]
      end

      #
      # Checks whether the given class declares any attributes.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(ctx)
        attributes_in(ctx).map do |_attribute, line|
          smell_warning(
            context: ctx,
            lines: [line],
            message: 'is a writable attribute')
        end
      end

      private

      # :reek:UtilityFunction
      def attributes_in(module_ctx)
        if module_ctx.visibility == :public
          call_node = module_ctx.exp
          [[call_node.name, call_node.line]]
        else
          []
        end
      end
    end
  end
end
