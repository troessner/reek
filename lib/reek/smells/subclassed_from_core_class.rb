# frozen_string_literal: true
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods or lines of code.
    #
    # +TooManyMethods+ reports classes having more than a configurable number
    # of methods. The method count includes public, protected and private
    # methods, and excludes methods inherited from superclasses or included
    # modules.
    #
    # See {file:docs/Too-Many-Methods.md} for details.
    class SubclassedFromCoreClass < SmellDetector
      CORE_CLASSES = [:Array, :Hash, :String]

      def self.contexts
        [:class]
      end

      # def self.default_config
      #   super.merge(
      #     MAX_ALLOWED_METHODS_KEY => DEFAULT_MAX_METHODS,
      #     EXCLUDE_KEY => []
      #   )
      # end

      #
      # Checks +ctx+ for if it is subclasssed from a core class
      #
      # @return [Array<SmellWarning>]
      def inspect(ctx)
        # max_allowed_methods = value(MAX_ALLOWED_METHODS_KEY, ctx, DEFAULT_MAX_METHODS)
        # TODO: Only checks instance methods!
        nodes = ctx.exp.to_a
        if ctx.namespace_module?
          _x, the_rest = *nodes
          _this_class, parent_class, _foo = the_rest.to_a
        else
        _this_class, parent_class, _foo = nodes
        end
        return [] if parent_class.nil?
        _, parent_class_name = parent_class.to_a
        return [] unless CORE_CLASSES.include?(parent_class_name)

        [smell_warning(
          context: ctx,
          lines: [ctx.exp.line],
          message: "inherits from a core class #{parent_class_name}",
          parameters: { count: 1 })]
      end
    end
  end
end
