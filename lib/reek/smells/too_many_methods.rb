require 'reek/smells/smell_detector'
require 'reek/smell_warning'

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
    class TooManyMethods < SmellDetector

      SMELL_CLASS = 'LargeClass'
      SMELL_SUBCLASS = self.name.split(/::/)[-1]
      METHOD_COUNT_KEY = 'method_count'

      # The name of the config field that sets the maximum number of methods
      # permitted in a class.
      MAX_ALLOWED_METHODS_KEY = 'max_methods'

      DEFAULT_MAX_METHODS = 25

      def self.contexts      # :nodoc:
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
        check_num_methods(ctx)
      end

    private

      def check_num_methods(ctx)  # :nodoc:
        actual = ctx.local_nodes(:defn).length
        return [] if actual <= @max_allowed_methods
        smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, [ctx.exp.line],
          "has at least #{actual} methods",
          @source, SMELL_SUBCLASS,
          {METHOD_COUNT_KEY => actual})
        [smell]
      end
    end
  end
end
