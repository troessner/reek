require_relative 'report/report'
require_relative 'report/formatter'
require_relative 'report/heading_formatter'

module Reek
  # Reek reporting functionality.
  module Report
    module_function

    REPORT_CLASSES = {
      yaml: YAMLReport,
      json: JSONReport,
      html: HTMLReport,
      xml: XMLReport,
      text: TextReport
    }

    LOCATION_FORMATTERS = {
      single_line: SingleLineLocationFormatter,
      plain: BlankLocationFormatter,
      numbers: DefaultLocationFormatter
    }

    HEADING_FORMATTERS = {
      verbose: HeadingFormatter::Verbose,
      quiet: HeadingFormatter::Quiet }

    WARNING_FORMATTER_CLASSES = {
      wiki_links: WikiLinkWarningFormatter,
      simple: SimpleWarningFormatter
    }

    # Map report format symbol to a report class.
    #
    # @param [Symbol] report_format The format to map
    #
    # @return The mapped report class
    #
    def report_class(report_format)
      REPORT_CLASSES.fetch(report_format) do
        raise "Unknown report format: #{report_format}"
      end
    end

    def location_formatter(location_format)
      LOCATION_FORMATTERS.fetch(location_format) do
        raise "Unknown location format: #{location_format}"
      end
    end

    def heading_formatter(heading_format)
      HEADING_FORMATTERS.fetch(heading_format) do
        raise "Unknown heading format: #{heading_format}"
      end
    end

    def warning_formatter_class(warning_format)
      WARNING_FORMATTER_CLASSES.fetch(warning_format) do
        raise "Unknown warning format: #{warning_format}"
      end
    end
  end
end
