require 'forwardable'
require_relative 'input'
require_relative '../report'

module Reek
  module CLI
    #
    # Interprets the options set from the command line
    #
    # @api private
    class OptionInterpreter
      include Input

      extend Forwardable

      def_delegators :options, :smells_to_detect

      def initialize(options)
        @options = options
        @argv = options.argv
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
        Report.report_class(options.report_format)
      end

      def warning_formatter
        warning_formatter_class.new(location_formatter)
      end

      def warning_formatter_class
        Report.warning_formatter_class(options.show_links ? :wiki_links : :simple)
      end

      def location_formatter
        Report.location_formatter(options.location_format)
      end

      def heading_formatter
        Report.heading_formatter(options.show_empty ? :verbose : :quiet)
      end

      def sort_by_issue_count
        options.sorting == :smelliness
      end

      private

      private_attr_reader :argv, :options
    end
  end
end
