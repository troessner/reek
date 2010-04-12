require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'examiner')

module Reek
  module Cli

    #
    # A command to collect smells from a set of sources and write them out in
    # text report format.
    #
    class ReekCommand
      def self.create(sources, report_class, config_files = [])
        new(report_class, sources, config_files)
      end

      def initialize(report_class, sources, config_files = [])
        @sources = sources
        @report_class = report_class
        @config_files = config_files
      end

      def execute(view)
        had_smells = false
        @sources.each do |source|
          examiner = Examiner.new(source, @config_files)
          rpt = @report_class.new(examiner)
          had_smells ||= examiner.smelly?
          view.output(rpt.report)
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
