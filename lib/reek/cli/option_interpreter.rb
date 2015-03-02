require 'forwardable'
require 'reek/cli/input'
require 'reek/cli/report/report'
require 'reek/cli/report/formatter'
require 'reek/cli/report/heading_formatter'

module Reek
  module Cli
    #
    # Interprets the options set from the command line
    #
    class OptionInterpreter
      include Cli::Input

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
          Report::YamlReport
        when :json
          Report::JsonReport
        when :html
          Report::HtmlReport
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
