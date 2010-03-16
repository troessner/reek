require 'set'

module Reek
  module Core

    #
    # Collects and sorts smells warnings.
    #
    class WarningCollector
      def initialize
        @warnings = Set.new
      end

      def found_smell(warning)
        @warnings.add(warning)
      end

      def warnings
        @warnings.to_a.sort do |first,second|
          first_sig = [first.context, first.message, first.smell_class]
          second_sig = [second.context, second.message, second.smell_class]
          first_sig <=> second_sig
        end
      end
    end
  end
end
