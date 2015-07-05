require 'set'

module Reek
  module CLI
    #
    # Collects and sorts smells warnings.
    #
    # @api private
    class WarningCollector
      def initialize
        @warnings = Set.new
      end

      def found_smell(warning)
        @warnings.add(warning)
      end

      def warnings
        @warnings.to_a.sort
      end
    end
  end
end
