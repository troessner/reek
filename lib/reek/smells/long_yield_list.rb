require 'reek/smells/smell_detector'

module Reek
  module Smells

    class LongYieldList < LongParameterList

      def self.contexts      # :nodoc:
        [:yield]
      end

      def initialize(config = LongYieldList.default_config)
        super
        @action = 'yields'
      end
    end
  end
end
