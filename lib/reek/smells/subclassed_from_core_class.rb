# frozen_string_literal: true
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    # TODO: documentation
    class SubclassedFromCoreClass < SmellDetector
      CORE_CLASSES = [:Array, :Hash, :String]

      def self.contexts
        [:class]
      end

      # Checks +ctx+ for if it is subclasssed from a core class
      #
      # @return [Array<SmellWarning>]
      def inspect(ctx)
        _class_node, ancestor_node, _body_node = ctx.exp.to_a
        return [] if ancestor_node.nil?
        ancestor_namespace, ancestor = ancestor_node.to_a
        return [] unless CORE_CLASSES.include?(ancestor) && ancestor_namespace.nil?

        [smell_warning(
          context: ctx,
          lines: [ctx.exp.line],
          message: "inherits from a core class #{ancestor}",
          parameters: { count: 1 })]
      end
    end
  end
end
