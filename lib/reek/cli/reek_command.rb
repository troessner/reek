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
        had_smells = false
        @sources.each do |source|
          examiner = Examiner.new(source, @config_files)
          had_smells ||= examiner.smelly?
          view.output @reporter.report(examiner)
        end
        if had_smells
          view.report_smells
        else
          view.report_success
        end
      end
    end
  end
end
