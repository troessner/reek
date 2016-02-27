# frozen_string_literal: true
require_relative 'base_command'
require_relative '../../examiner'

module Reek
  module CLI
    module Command
      #
      # A command to collect smells from a set of sources and write them out in
      # text report format.
      #
      class ReportCommand < BaseCommand
        def execute(app)
          populate_reporter_with_smells app
          reporter.show
          result_code
        end

        private

        def populate_reporter_with_smells(app)
          sources.each do |source|
            reporter.add_examiner Examiner.new(source,
                                               filter_by_smells: smell_names,
                                               configuration: app.configuration)
          end
        end

        def result_code
          reporter.smells? ? options.failure_exit_code : options.success_exit_code
        end

        def reporter
          @reporter ||= options.reporter
        end
      end
    end
  end
end
