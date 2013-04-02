require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    #
    # A variant on LongParameterList that checks the number of items
    # passed to a block by a +yield+ call.
    #
    class LongYieldList < SmellDetector

      SMELL_CLASS = 'LongParameterList'
      SMELL_SUBCLASS = self.name.split(/::/)[-1]

      # The name of the config field that sets the maximum number of
      # parameters permitted in any method or block.
      MAX_ALLOWED_PARAMS_KEY = 'max_params'

      # The default value of the +MAX_ALLOWED_PARAMS_KEY+ configuration
      # value.
      DEFAULT_MAX_ALLOWED_PARAMS = 3

      PARAMETER_COUNT_KEY = 'parameter_count'

      def self.default_config
        super.adopt(
          MAX_ALLOWED_PARAMS_KEY => DEFAULT_MAX_ALLOWED_PARAMS
        )
      end

      #
      # Checks the number of parameters in the given scope.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(method_ctx)
        @max_allowed_params = value(MAX_ALLOWED_PARAMS_KEY, method_ctx, DEFAULT_MAX_ALLOWED_PARAMS)
        method_ctx.local_nodes(:yield).select do |yield_node|
          yield_node.args.length > @max_allowed_params
        end.map do |yield_node|
          num_params = yield_node.args.length
          SmellWarning.new(SMELL_CLASS, method_ctx.full_name, [yield_node.line],
                           "yields #{num_params} parameters",
                           @source, SMELL_SUBCLASS, {PARAMETER_COUNT_KEY => num_params})
        end
      end
    end
  end
end
