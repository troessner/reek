$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

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
    class LongParameterList < Smell

      #
      # Checks whether the given conditional statement relies on a control couple.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine(ctx, report)
        num_params = count_parameters(ctx.parameters)
        return false if num_params <= MAX_ALLOWED
        report << new(ctx, num_params)
        return true
      end

      MAX_ALLOWED = 3

      def self.count_parameters(params)
        result = params.length
        result -= 1 if Array === params[-1] and params[-1][0] == :block
        result
      end
      
      def initialize(context, num_params)
        super(context)
        @num_params = num_params
      end

      def detailed_report
        "#{@context.to_s} has #{@num_params} parameters"
      end
    end

  end
end
