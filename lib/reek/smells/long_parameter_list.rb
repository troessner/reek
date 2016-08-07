# frozen_string_literal: true
require_relative 'smell_configuration'
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # A Long Parameter List occurs when a method has more than one
    # or two parameters, or when a method yields more than one or
    # two objects to an associated block.
    #
    # Currently +LongParameterList+ reports any method or block with too
    # many parameters.
    #
    # See {file:docs/Long-Parameter-List.md} for details.
    class LongParameterList < SmellDetector
      # The name of the config field that sets the maximum number of
      # parameters permitted in any method or block.
      MAX_ALLOWED_PARAMS_KEY = 'max_params'.freeze
      DEFAULT_MAX_ALLOWED_PARAMS = 3

      def self.default_config
        super.merge(
          MAX_ALLOWED_PARAMS_KEY => DEFAULT_MAX_ALLOWED_PARAMS,
          SmellConfiguration::OVERRIDES_KEY => {
            'initialize' => { MAX_ALLOWED_PARAMS_KEY => 5 }
          })
      end

      #
      # Checks the number of parameters in the given method.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(ctx)
        max_allowed_params = value(MAX_ALLOWED_PARAMS_KEY, ctx)
        exp = ctx.exp
        count = exp.arg_names.length
        return [] if count <= max_allowed_params
        [smell_warning(
          context: ctx,
          lines: [exp.line],
          message: "has #{count} parameters",
          parameters: { count: count })]
      end
    end
  end
end
