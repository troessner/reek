require 'reek/smells/smell_detector'
require 'reek/smell_warning'

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

      def self.default_config
        super.adopt(MAX_ALLOWED_PARAMS_KEY => 3)
      end

      def initialize(config)
        super
        @max_params = config['max_params']
        @action = 'has'
      end

      #
      # Checks the number of parameters in the given scope.
      # Any smells found are added to the +report+.
      #
      def examine_context(ctx, report)
        num_params = ctx.parameters.length
        return false if num_params <= @max_params
        report << SmellWarning.new(self, ctx,
                    "#{@action} #{num_params} parameters")
      end
    end
  end
end
