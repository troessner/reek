require_relative 'smell_detector'

module Reek
  module Smells
    #
    # A variant on LongParameterList that checks the number of items
    # passed to a block by a +yield+ call.
    #
    # See docs/Long-Yield-List for details.
    class LongYieldList < SmellDetector
      # The name of the config field that sets the maximum number of
      # parameters permitted in any method or block.
      MAX_ALLOWED_PARAMS_KEY = 'max_params'
      DEFAULT_MAX_ALLOWED_PARAMS = 3

      def self.smell_category
        'LongParameterList'
      end

      def self.default_config
        super.merge MAX_ALLOWED_PARAMS_KEY => DEFAULT_MAX_ALLOWED_PARAMS
      end

      #
      # Checks the number of parameters in the given scope.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(method_ctx)
        @max_allowed_params = value(MAX_ALLOWED_PARAMS_KEY,
                                    method_ctx,
                                    DEFAULT_MAX_ALLOWED_PARAMS)
        method_ctx.local_nodes(:yield).select do |yield_node|
          yield_node.args.length > @max_allowed_params
        end.map do |yield_node|
          count = yield_node.args.length
          SmellWarning.new self,
                           context: method_ctx.full_name,
                           lines: [yield_node.line],
                           message: "yields #{count} parameters",
                           parameters: { count: count }
        end
      end
    end
  end
end
