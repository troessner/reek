# frozen_string_literal: true
require_relative 'report/code_climate'
require_relative 'report/html_report'
require_relative 'report/json_report'
require_relative 'report/text_report'
require_relative 'report/xml_report'
require_relative 'report/yaml_report'
require_relative 'report/formatter'

module Reek
  # Reek reporting functionality.
  module Report
    REPORT_CLASSES = {
      yaml: YAMLReport,
      json: JSONReport,
      html: HTMLReport,
      xml: XMLReport,
      text: TextReport,
      code_climate: CodeClimateReport
    }.freeze

    LOCATION_FORMATTERS = {
      single_line: Formatter::SingleLineLocationFormatter,
      plain: Formatter::BlankLocationFormatter,
      numbers: Formatter::DefaultLocationFormatter
    }.freeze

    HEADING_FORMATTERS = {
      verbose: Formatter::VerboseHeadingFormatter,
      quiet: Formatter::QuietHeadingFormatter
    }.freeze

    WARNING_FORMATTER_CLASSES = {
      wiki_links: Formatter::WikiLinkWarningFormatter,
      simple: Formatter::SimpleWarningFormatter
    }.freeze

    # Map report format symbol to a report class.
    #
    # @param [Symbol] report_format The format to map
    #
    # @return The mapped report class
    #
    def self.report_class(report_format)
      REPORT_CLASSES.fetch(report_format)
    end

    # Map location format symbol to a report class.
    #
    # @param [Symbol] location_format The format to map
    #
    # @return The mapped location class
    #
    def self.location_formatter(location_format)
      LOCATION_FORMATTERS.fetch(location_format)
    end

    # Map heading format symbol to a report class.
    #
    # @param [Symbol] heading_format The format to map
    #
    # @return The mapped heading class
    #
    def self.heading_formatter(heading_format)
      HEADING_FORMATTERS.fetch(heading_format)
    end

    # Map warning format symbol to a report class.
    #
    # @param [Symbol] warning_format The format to map
    #
    # @return The mapped warning class
    #
    def self.warning_formatter_class(warning_format)
      WARNING_FORMATTER_CLASSES.fetch(warning_format)
    end
  end
end
