# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # a module is usually a mixin, so when initialize method is present it is
    # hard to tell initialization order and parameters so having 'initialize'
    # in a module is usually a bad idea
    #
    # See {file:docs/Module-Initialize.md} for details.
    class ModuleInitialize < BaseDetector
      def self.contexts # :nodoc:
        [:module]
      end

      #
      # Checks whether module has method 'initialize'.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        context.local_nodes(:def) do |node|
          if node.name == :initialize
            return smell_warning(
              context: context,
              lines:   [source_line],
              message: 'has initialize method')
          end
        end
        []
      end
    end
  end
end
