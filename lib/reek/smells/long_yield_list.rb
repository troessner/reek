$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    class LongYieldList < LongParameterList
      def recognise?(args)
        @num_params = args.length
        Array === args and @num_params > MAX_ALLOWED
      end

      def detailed_report
        "#{@context} yields #{@num_params} parameters"
      end
    end

  end
end
