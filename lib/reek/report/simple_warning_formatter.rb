# frozen_string_literal: true

module Reek
  module Report
    #
    # Basic formatter that just shows a simple message for each warning,
    # prepended with the result of the passed-in location formatter.
    #
    class SimpleWarningFormatter
      def initialize(location_formatter: BlankLocationFormatter)
        @location_formatter = location_formatter
      end

      def format(warning)
        "#{location_formatter.format(warning)}#{warning.base_message}"
      end

      def format_list(warnings)
        warnings.map { |warning| "  #{format(warning)}" }.join("\n")
      end

      private

      attr_reader :location_formatter
    end
  end
end
