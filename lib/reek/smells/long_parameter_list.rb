require 'reek/smells/smell_detector'
require 'reek/smell_warning'
require 'reek/core/smell_configuration'

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
    class LongParameterList < SmellDetector

      SMELL_CLASS = 'LongParameterList'
      SMELL_SUBCLASS = self.name.split(/::/)[-1]

      PARAMETER_COUNT_KEY = 'parameter_count'

      # The name of the config field that sets the maximum number of
      # parameters permitted in any method or block.
      MAX_ALLOWED_PARAMS_KEY = 'max_params'

      # The default value of the +MAX_ALLOWED_PARAMS_KEY+ configuration
      # value.
      DEFAULT_MAX_ALLOWED_PARAMS = 3

      def self.default_config
        super.adopt(
          MAX_ALLOWED_PARAMS_KEY => DEFAULT_MAX_ALLOWED_PARAMS,
          Core::SmellConfiguration::OVERRIDES_KEY => {
            "initialize" => {MAX_ALLOWED_PARAMS_KEY => 5}
          }
        )
      end

      #
      # Checks the number of parameters in the given method.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        @max_allowed_params = value(MAX_ALLOWED_PARAMS_KEY, ctx, DEFAULT_MAX_ALLOWED_PARAMS)
        num_params = ctx.exp.arg_names.length
        return [] if num_params <= @max_allowed_params
        smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, [ctx.exp.line],
          "has #{num_params} parameters",
          @source, SMELL_SUBCLASS,
          {PARAMETER_COUNT_KEY => num_params})
        [smell]
      end
    end
  end
end
