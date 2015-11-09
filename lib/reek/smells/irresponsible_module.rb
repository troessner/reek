require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # It is considered good practice to annotate every class and module
    # with a brief comment outlining its responsibilities.
    #
    # See {file:docs/Irresponsible-Module.md} for details.
    class IrresponsibleModule < SmellDetector
      def self.contexts
        [:casgn, :class, :module]
      end

      #
      # Checks the given class or module for a descriptive comment.
      #
      # @return [Array<SmellWarning>]
      #
      def inspect(ctx)
        return [] if descriptive?(ctx) || ctx.namespace_module?
        expression = ctx.exp
        [smell_warning(
          context: ctx,
          lines: [expression.line],
          message: 'has no descriptive comment',
          parameters: { name: expression.name })]
      end

      private

      def descriptive
        @descriptive ||= {}
      end

      # :reek:FeatureEnvy
      def descriptive?(ctx)
        descriptive[ctx.full_name] ||= ctx.descriptively_commented?
      end
    end
  end
end
