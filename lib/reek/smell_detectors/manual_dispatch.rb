# frozen_string_literal: true

require_relative 'base_detector'

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
      def sniff
        smelly_nodes = context.each_node(:send).select { |node| node.name == :respond_to? }
        return [] if smelly_nodes.empty?
        lines = smelly_nodes.map(&:line)
        [smell_warning(context: context, lines: lines, message: MESSAGE)]
      end
    end
  end
end
