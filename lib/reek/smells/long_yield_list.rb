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
        @action = 'yields'
      end
    end
  end
end
