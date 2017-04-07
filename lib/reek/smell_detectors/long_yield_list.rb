# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # A variant on LongParameterList that checks the number of items
    # passed to a block by a +yield+ call.
    #
    # See {file:docs/Long-Yield-List.md} for details.
    class LongYieldList < BaseDetector
      # The name of the config field that sets the maximum number of
      # parameters permitted in any method or block.
      MAX_ALLOWED_PARAMS_KEY = 'max_params'.freeze
      DEFAULT_MAX_ALLOWED_PARAMS = 3

      def self.default_config
        super.merge MAX_ALLOWED_PARAMS_KEY => DEFAULT_MAX_ALLOWED_PARAMS
      end

      #
      # Checks the number of parameters in the given scope.
      #
      # @return [Array<SmellWarning>]
      #
      # :reek:FeatureEnvy
      # :reek:DuplicateMethodCall: { max_calls: 2 }
      def sniff(ctx)
        max_allowed_params = value(MAX_ALLOWED_PARAMS_KEY, ctx)
        ctx.local_nodes(:yield).select do |yield_node|
          yield_node.args.length > max_allowed_params
        end.map do |yield_node|
          count = yield_node.args.length
          smell_warning(
            context: ctx,
            lines: [yield_node.line],
            message: "yields #{count} parameters",
            parameters: { count: count })
        end
      end
    end
  end
end
