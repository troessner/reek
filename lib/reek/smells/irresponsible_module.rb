require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # It is considered good practice to annotate every class and module
    # with a brief comment outlining its responsibilities.
    #
    # See {file:docs/Irresponsible-Module.md} for details.
    # @api private
    class IrresponsibleModule < SmellDetector
      def self.contexts # :nodoc:
        [:class]
      end

      def descriptive   # :nodoc:
        @descriptive ||= {}
      end

      #
      # Checks the given class or module for a descriptive comment.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        return [] if descriptive?(ctx)
        expression = ctx.exp
        [SmellWarning.new(self,
                          context: ctx.full_name,
                          lines: [expression.line],
                          message: 'has no descriptive comment',
                          parameters: {  name: expression.text_name })]
      end

      def descriptive?(ctx)
        descriptive[ctx.full_name] ||= ctx.descriptively_commented?
      end
    end
  end
end
