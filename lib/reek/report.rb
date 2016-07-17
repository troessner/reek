# frozen_string_literal: true
require_relative 'report/report'
require_relative 'report/formatter'
require_relative 'report/heading_formatter'

module Reek
  # Reek reporting functionality.
  module Report
    REPORT_CLASSES = {
      yaml: YAMLReport,
      json: JSONReport,
      html: HTMLReport,
      xml: XMLReport,
      text: TextReport,
      progress: ProgressReport,
      code_climate: CodeClimateReport
    }.freeze

    LOCATION_FORMATTERS = {
      single_line: SingleLineLocationFormatter,
      plain: BlankLocationFormatter,
      numbers: DefaultLocationFormatter
    }.freeze

    HEADING_FORMATTERS = {
      verbose: HeadingFormatter::Verbose,
      quiet: HeadingFormatter::Quiet
    }.freeze

    WARNING_FORMATTER_CLASSES = {
      wiki_links: WikiLinkWarningFormatter,
      simple: SimpleWarningFormatter
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
