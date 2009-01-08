$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # A Long Parameter List occurs when a method has more than one
    # or two parameters, or when a method yields more than one or
    # two objects to an associated block.
    #
    # Currently +LongParameterList+ reports any method with more
    # than +MAX_ALLOWED+ parameters.
    #
    class LongParameterList < SmellDetector

      def initialize(config = {})
        super
        @max_params = config.fetch('max_params', 3)
        @action = 'has'
      end
      
      #
      # Checks the number of parameters in the given scope.
      # Any smells found are added to the +report+.
      #
      def examine_context(ctx, report)
        num_params = ctx.parameters.length
        return false if num_params <= @max_params
        report << SmellWarning.new(smell_name, ctx,
                    "#{@action} #{num_params} parameters")
      end
    end
  end
end
