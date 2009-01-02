$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'

module Reek
  module Smells

    class LongYieldList < LongParameterList

      def self.contexts      # :nodoc:
        [:yield]
      end
      
      def create_report(ctx, num_params)
        LongYieldListReport.new(ctx, num_params)
      end
    end

    class LongYieldListReport < SmellReport
      
      def initialize(context, num_params)
        super(context)
        @num_params = num_params
      end

      def warning
        "yields #{@num_params} parameters"
      end
    end
  end
end
