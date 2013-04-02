require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods or lines of code.
    # 
    # +TooManyInstanceVariables' reports classes having more than a
    # configurable number of instance variables.
    #
    class TooManyInstanceVariables < SmellDetector

      SMELL_CLASS = 'LargeClass'
      SMELL_SUBCLASS = self.name.split(/::/)[-1]
      IVAR_COUNT_KEY = 'ivar_count'

      # The name of the config field that sets the maximum number of instance
      # variables permitted in a class.
      MAX_ALLOWED_IVARS_KEY = 'max_instance_variables'

      DEFAULT_MAX_IVARS = 9

      def self.contexts      # :nodoc:
        [:class]
      end

      def self.default_config
        super.adopt(
          MAX_ALLOWED_IVARS_KEY => DEFAULT_MAX_IVARS,
          EXCLUDE_KEY => []
        )
      end

      #
      # Checks +klass+ for too many instance variables.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        @max_allowed_ivars = value(MAX_ALLOWED_IVARS_KEY, ctx, DEFAULT_MAX_IVARS)
        check_num_ivars(ctx)
      end

    private

      def check_num_ivars(ctx)  # :nodoc:
        count = ctx.local_nodes(:iasgn).map {|iasgn| iasgn[1]}.uniq.length
        return [] if count <= @max_allowed_ivars
        smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, [ctx.exp.line],
          "has at least #{count} instance variables",
          @source, SMELL_SUBCLASS,
          {IVAR_COUNT_KEY => count})
        [smell]
      end
    end
  end
end
