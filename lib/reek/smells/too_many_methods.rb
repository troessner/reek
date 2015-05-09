require_relative 'smell_detector'

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
    # See docs/Too-Many-Methods for details.
    class TooManyMethods < SmellDetector
      # The name of the config field that sets the maximum number of methods
      # permitted in a class.
      MAX_ALLOWED_METHODS_KEY = 'max_methods'
      DEFAULT_MAX_METHODS = 25

      def self.smell_category
        'LargeClass'
      end

      def self.contexts # :nodoc:
        [:class]
      end

      def self.default_config
        super.merge(
          MAX_ALLOWED_METHODS_KEY => DEFAULT_MAX_METHODS,
          EXCLUDE_KEY => []
        )
      end

      #
      # Checks +ctx+ for too many methods
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        @max_allowed_methods = value(MAX_ALLOWED_METHODS_KEY, ctx, DEFAULT_MAX_METHODS)
        actual = ctx.node_instance_methods.length
        return [] if actual <= @max_allowed_methods
        [SmellWarning.new(self,
                          context: ctx.full_name,
                          lines: [ctx.exp.line],
                          message:  "has at least #{actual} methods",
                          parameters: { count: actual })]
      end
    end
  end
end
