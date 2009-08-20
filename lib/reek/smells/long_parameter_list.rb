require 'reek/smells/smell_detector'

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

      # The name of the config field that sets the maximum number of
      # parameters permitted in any method or block.
      MAX_ALLOWED_PARAMS_KEY = 'max_params'

      # The default value of the +MAX_ALLOWED_PARAMS_KEY+ configuration
      # value.
      DEFAULT_MAX_ALLOWED_PARAMS = 3

      def self.default_config
        super.adopt(
          MAX_ALLOWED_PARAMS_KEY => DEFAULT_MAX_ALLOWED_PARAMS,
          SmellConfiguration::OVERRIDES_KEY => {
            "initialize" => {MAX_ALLOWED_PARAMS_KEY => 5}
            }
        )
      end

      def initialize(config = LongParameterList.default_config)
        super(config)
        @action = 'has'
      end

      #
      # Checks the number of parameters in the given scope.
      # Remembers any smells found.
      #
      def examine_context(ctx)
        num_params = ctx.parameters.length
        return false if num_params <= value(MAX_ALLOWED_PARAMS_KEY, ctx, DEFAULT_MAX_ALLOWED_PARAMS)
        found(ctx, "#{@action} #{num_params} parameters")
      end
    end
  end
end
