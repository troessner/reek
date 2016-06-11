# frozen_string_literal: true
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    # TODO: documentation
    class SubclassedFromCoreClass < SmellDetector

      METHODS = {
        casgn: :inspect_casgn,
        class: :inspect_class,
      }.freeze

      def self.contexts
        [:class, :casgn]
      end

      # Checks +ctx+ for if it is subclasssed from a core class
      #
      # @return [Array<SmellWarning>]
      def inspect(ctx)
        public_send(METHODS[ctx.type], ctx)
      end

      def inspect_class(ctx)
        expression = ctx.exp
        superclass = expression.superclass

        return [] unless expression.superclass? && superclass.core_class?

        [smell_warning(
          context: ctx,
          lines: [ctx.exp.line],
          message: "inherits from a core class #{superclass}",
          parameters: { ancestor: superclass.name })]
      end

      def inspect_casgn(ctx)
        expression = ctx.exp
        assignment = expression.assignment

        return [] unless expression.class_creation? && assignment.emitted.core_class?

        ancestor = assignment.emitted

        [smell_warning(
          context: ctx,
          lines: [ctx.exp.line],
          message: "inherits from a core class #{ancestor}",
          parameters: { ancestor: ancestor.name })]
      end
    end
  end
end
