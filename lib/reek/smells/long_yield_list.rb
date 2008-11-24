$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    class LongYieldList < LongParameterList

      #
      # Checks the arguments to the given call to yield.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine(ctx, report)
        args = ctx.args
        return false unless Array === args and args[0] == :array
        if (args.length - 1) > MAX_ALLOWED
          report << new(ctx, args.length-1)
          return true
        else
          return false
        end
      end

      def initialize(context, num_params)
        super(context)
        @num_params = num_params
      end

      def detailed_report
        "#{@context} yields #{@num_params} parameters"
      end
    end

  end
end
