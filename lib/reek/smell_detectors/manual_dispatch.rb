# frozen_string_literal: true
require_relative 'base_detector'
require_relative 'smell_warning'

module Reek
  module SmellDetectors
    #
    # A Manual Dispatch occurs when a method is only called after a
    # manual check that the method receiver is of the correct type.
    #
    # The +ManualDispatch+ checker reports any invocation of +respond_to?+
    #
    # See {file:docs/Manual-Dispatch.md} for details.
    class ManualDispatch < BaseDetector
      MESSAGE = 'manually dispatches method call'.freeze

      #
      # Checks for +respond_to?+ usage within the given method
      #
      # @return [Array<SmellWarning>]
      #
      # :reek:FeatureEnvy
      def sniff(ctx)
        ctx.each_node(:send).flat_map do |node|
          next unless node.name.equal?(:respond_to?)

          smell_warning(context: ctx, lines: [node.line], message: MESSAGE)
        end.compact
      end
    end
  end
end
