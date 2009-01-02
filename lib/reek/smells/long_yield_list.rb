$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'

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
        return false if num_args <= @@max_params
        report << LongYieldListReport.new(ctx, num_args)
      end

      def self.contexts      # :nodoc:
        [:yield]
      end
    end

    class LongYieldListReport < SmellReport
      
      def initialize(context, num_params)
        super(context)
        @num_params = num_params
      end

      def detailed_report
        "#{@context.to_s} yields #{@num_params} parameters"
      end
    end
  end
end
