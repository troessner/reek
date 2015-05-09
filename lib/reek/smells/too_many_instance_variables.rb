require_relative 'smell_detector'

module Reek
  module Smells
    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods or lines of code.
    #
    # +TooManyInstanceVariables' reports classes having more than a
    # configurable number of instance variables.
    #
    # See docs/Too-Many-Instance-Variables for details.
    class TooManyInstanceVariables < SmellDetector
      # The name of the config field that sets the maximum number of instance
      # variables permitted in a class.
      MAX_ALLOWED_IVARS_KEY = 'max_instance_variables'
      DEFAULT_MAX_IVARS = 9

      def self.smell_category
        'LargeClass'
      end

      def self.contexts      # :nodoc:
        [:class]
      end

      def self.default_config
        super.merge(
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
        count = ctx.local_nodes(:ivasgn).map { |ivasgn| ivasgn[1] }.uniq.length
        return [] if count <= @max_allowed_ivars
        [SmellWarning.new(self,
                          context: ctx.full_name,
                          lines: [ctx.exp.line],
                          message: "has at least #{count} instance variables",
                          parameters: { count: count })]
      end
    end
  end
end
