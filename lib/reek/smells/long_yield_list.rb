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
      def self.examine_context(ctx, report)
        args = ctx.args
        return false unless Array === args and args[0] == :array
        num_args = args.length-1
        return false if num_args <= config[MAX_PARAMS_KEY]
        report << new(ctx, num_args)
      end

      def self.contexts      # :nodoc:
        [:yield]
      end

      def detailed_report
        "#{@context.to_s} yields #{@num_params} parameters"
      end
    end

  end
end
