require 'reek/examiner'

module Reek
  module Cli

    #
    # A command to collect smells from a set of sources and write them out in
    # text report format.
    #
    class ReekCommand
      def self.create(sources, reporter, config_files = [])
        new(reporter, sources, config_files)
      end

      def initialize(reporter, sources, config_files = [])
        @sources = sources
        @reporter = reporter
        @config_files = config_files
      end

      def execute(view)
        total_smells_count = 0
        @sources.each do |source|
          examiner = Examiner.new(source, @config_files)
          total_smells_count += examiner.smells_count
          view.output @reporter.report(examiner)
        end
        if total_smells_count > 0
          view.report_smells
        else
          view.report_success
        end

        view.output_smells_total(total_smells_count) if @sources.count > 1
      end
    end
  end
end
