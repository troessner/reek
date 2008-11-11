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
      MAX_ALLOWED = 3

      def self.count_parameters(exp)
        result = exp.length - 1
        result -= 1 if Array === exp[-1] and exp[-1][0] == :block
        result
      end

      def recognise?(args)
        @num_params = LongParameterList.count_parameters(args)
        @num_params > MAX_ALLOWED
      end

      def detailed_report
        "#{@context.to_s} has #{@num_params} parameters"
      end
    end

  end
end
