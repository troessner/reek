# frozen_string_literal: true

require_relative 'base_command'
require_relative '../../examiner'
require_relative '../../logging_error_handler'
require_relative '../../report'

module Reek
  module CLI
    module Command
      #
      # A command to collect smells from a set of sources and write them out in
      # text report format.
      #
      class ReportCommand < BaseCommand
        def execute
          populate_reporter_with_smells
          reporter.show
          result_code
        end

        private

        def populate_reporter_with_smells
          sources.each do |source|
            reporter.add_examiner Examiner.new(source,
                                               filter_by_smells: smell_names,
                                               configuration: configuration,
                                               error_handler: LoggingErrorHandler.new)
          end
        end

        def result_code
          reporter.smells? ? options.failure_exit_code : options.success_exit_code
        end

        def reporter
          @reporter ||=
            report_class.new(
              warning_formatter: warning_formatter,
              report_formatter: Report::Formatter,
              sort_by_issue_count: sort_by_issue_count,
              heading_formatter: heading_formatter,
              progress_formatter: progress_formatter.new(sources.length))
        end

        def report_class
          Report.report_class(options.report_format)
        end

        def warning_formatter
          warning_formatter_class.new(location_formatter: location_formatter)
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

        def progress_formatter
          Report.progress_formatter(options.progress_format)
        end

        def sort_by_issue_count
          options.sorting == :smelliness
        end
      end
    end
  end
end
