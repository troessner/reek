# frozen_string_literal: true

require_relative 'report/html_report'
require_relative 'report/json_report'
require_relative 'report/text_report'
require_relative 'report/xml_report'
require_relative 'report/yaml_report'

require_relative 'report/heading_formatter'
require_relative 'report/location_formatter'
require_relative 'report/progress_formatter'
require_relative 'report/simple_warning_formatter'
require_relative 'report/documentation_link_warning_formatter'

module Reek
  # Reek reporting functionality.
  module Report
    REPORT_CLASSES = {
      yaml: YAMLReport,
      json: JSONReport,
      html: HTMLReport,
      xml:  XMLReport,
      text: TextReport
    }.freeze

    LOCATION_FORMATTERS = {
      single_line: SingleLineLocationFormatter,
      plain:       BlankLocationFormatter,
      numbers:     DefaultLocationFormatter
    }.freeze

    HEADING_FORMATTERS = {
      verbose: VerboseHeadingFormatter,
      quiet:   QuietHeadingFormatter
    }.freeze

    PROGRESS_FORMATTERS = {
      dots:  ProgressFormatter::Dots,
      quiet: ProgressFormatter::Quiet
    }.freeze

    WARNING_FORMATTER_CLASSES = {
      documentation_links: DocumentationLinkWarningFormatter,
      simple:              SimpleWarningFormatter
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

    # Map progress format symbol to a report class.
    #
    # @param [Symbol] progress_format The format to map
    #
    # @return The mapped progress class
    #
    def self.progress_formatter(progress_format)
      PROGRESS_FORMATTERS.fetch(progress_format)
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
