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
        return [] if does_not_have_initializer_method?

        smell_warning(lines: [source_line], message: 'has initialize method')
      end

      private

      # :reek:FeatureEnvy
      def does_not_have_initializer_method?
        context.exp.direct_children.none? { |child| child.type == :def && child.name == :initialize }
      end
    end
  end
end
