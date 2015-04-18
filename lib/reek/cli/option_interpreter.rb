require 'forwardable'
require_relative 'input'
require_relative 'report/report'
require_relative 'report/formatter'
require_relative 'report/heading_formatter'

module Reek
  module CLI
    #
    # Interprets the options set from the command line
    #
    class OptionInterpreter
      include CLI::Input

      extend Forwardable

      def_delegators :@options, :smells_to_detect

      def initialize(options)
        @options = options
        @argv = @options.argv
      end

      def reporter
        @reporter ||=
          report_class.new(
            warning_formatter: warning_formatter,
            report_formatter: Report::Formatter,
            sort_by_issue_count: sort_by_issue_count,
            heading_formatter: heading_formatter)
      end

      def report_class
        case @options.report_format
        when :yaml
          Report::YAMLReport
        when :json
          Report::JSONReport
        when :html
          Report::HTMLReport
        when :xml
          Report::XMLReport
        else # :text
          Report::TextReport
        end
      end

      def warning_formatter
        klass = if @options.show_links
                  Report::WikiLinkWarningFormatter
                else
                  Report::SimpleWarningFormatter
                end
        klass.new(location_formatter)
      end

      def location_formatter
        case @options.location_format
        when :single_line
          Report::SingleLineLocationFormatter
        when :plain
          Report::BlankLocationFormatter
        else # :numbers
          Report::DefaultLocationFormatter
        end
      end

      def heading_formatter
        if @options.show_empty
          Report::HeadingFormatter::Verbose
        else
          Report::HeadingFormatter::Quiet
        end
      end

      def sort_by_issue_count
        @options.sorting == :smelliness
      end
    end
  end
end
