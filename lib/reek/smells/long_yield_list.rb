$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'

module Reek
  module Smells

    class LongYieldList < LongParameterList

      def self.contexts      # :nodoc:
        [:yield]
      end

      def initialize(config = {})
        super
        @max_params = config.fetch('max_params', 3)
        @report_class = LongYieldListReport
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
