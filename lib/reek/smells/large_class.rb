require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

module Reek
  module Smells

    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods or lines of code.
    # 
    # Currently +LargeClass+ only reports classes having more than a
    # configurable number of methods or instance variables. The method count
    # includes public, protected and
    # private methods, and excludes methods inherited from superclasses or
    # included modules.
    #
    class LargeClass < SmellDetector

      SMELL_CLASS = self.name.split(/::/)[-1]
      SUBCLASS_TOO_MANY_METHODS = 'TooManyMethods'
      SUBCLASS_TOO_MANY_IVARS = 'TooManyInstanceVariables'
      METHOD_COUNT_KEY = 'method_count'
      IVAR_COUNT_KEY = 'ivar_count'

      # The name of the config field that sets the maximum number of methods
      # permitted in a class.
      MAX_ALLOWED_METHODS_KEY = 'max_methods'

      DEFAULT_MAX_METHODS = 25

      # The name of the config field that sets the maximum number of instance
      # variables permitted in a class.
      MAX_ALLOWED_IVARS_KEY = 'max_instance_variables'

      DEFAULT_MAX_IVARS = 9

      def self.contexts      # :nodoc:
        [:class]
      end

      def self.default_config
        super.adopt(
          MAX_ALLOWED_METHODS_KEY => DEFAULT_MAX_METHODS,
          MAX_ALLOWED_IVARS_KEY => DEFAULT_MAX_IVARS,
          EXCLUDE_KEY => []
          )
      end

      def initialize(source, config = LargeClass.default_config)
        super(source, config)
      end

      #
      # Checks +klass+ for too many methods or too many instance variables.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        @max_allowed_ivars = value(MAX_ALLOWED_IVARS_KEY, ctx, DEFAULT_MAX_IVARS)
        @max_allowed_methods = value(MAX_ALLOWED_METHODS_KEY, ctx, DEFAULT_MAX_METHODS)
        check_num_methods(ctx) + check_num_ivars(ctx)
      end

    private

      def check_num_methods(ctx)  # :nodoc:
        actual = ctx.local_nodes(:defn).length
        return [] if actual <= @max_allowed_methods
        smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, [ctx.exp.line],
          "has at least #{actual} methods",
          @source, SUBCLASS_TOO_MANY_METHODS,
          {METHOD_COUNT_KEY => actual})
        [smell]
      end

      def check_num_ivars(ctx)  # :nodoc:
        count = ctx.local_nodes(:iasgn).map {|iasgn| iasgn[1]}.uniq.length
        return [] if count <= @max_allowed_ivars
        smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, [ctx.exp.line],
          "has at least #{count} instance variables",
          @source, SUBCLASS_TOO_MANY_IVARS,
          {IVAR_COUNT_KEY => count})
        [smell]
      end
    end
  end
end
