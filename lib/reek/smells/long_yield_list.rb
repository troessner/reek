require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # A variant on LongParameterList that checks the number of items
    # passed to a block by a +yield+ call.
    #
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
