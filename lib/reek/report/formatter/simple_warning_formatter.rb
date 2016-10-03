# frozen_string_literal: true

module Reek
  module Report
    module Formatter
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

        # :reek:UtilityFunction
        def format_hash(warning)
          warning.yaml_hash
        end

        # :reek:UtilityFunction
        def format_code_climate_hash(warning)
          CodeClimateFormatter.new(warning).render
        end

        private

        attr_reader :location_formatter
      end
    end
  end
end
