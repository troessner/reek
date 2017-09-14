# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # It is considered good practice to annotate every class and module
    # with a brief comment outlining its responsibilities.
    #
    # See {file:docs/Irresponsible-Module.md} for details.
    class IrresponsibleModule < BaseDetector
      def self.contexts
        [:casgn, :class, :module]
      end

      #
      # Checks the given class or module for a descriptive comment.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        return [] if descriptive_context? || context.namespace_module?
        [smell_warning(
          context: context,
          lines: [source_line],
          message: 'has no descriptive comment')]
      end

      private

      def descriptive_context?
        context.descriptively_commented?
      end
    end
  end
end
