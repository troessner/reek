# frozen_string_literal: true

require_relative 'code_climate/code_climate_formatter'
require_relative 'formatter/heading_formatter'
require_relative 'formatter/location_formatter'
require_relative 'formatter/progress_formatter'
require_relative 'formatter/simple_warning_formatter'
require_relative 'formatter/wiki_link_warning_formatter'

module Reek
  module Report
    #
    # Formatter handling the formatting of the report at large.
    # Formatting of the individual warnings is handled by the
    # passed-in warning formatter.
    #
    module Formatter
      module_function

      def format_list(warnings, formatter: SimpleWarningFormatter.new)
        warnings.map { |warning| "  #{formatter.format(warning)}" }.join("\n")
      end

      def header(examiner)
        count = examiner.smells_count
        result = Rainbow("#{examiner.description} -- ").cyan +
          Rainbow("#{count} warning").yellow
        result += Rainbow('s').yellow unless count == 1
        result
      end
    end
  end
end
