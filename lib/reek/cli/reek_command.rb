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
        @total_smells_count = 0
        @sources.each do |source|
          examiner = Examiner.new(source, @config_files)
          @total_smells_count += examiner.smells_count 
          view.output @reporter.report(examiner)
        end
        if @total_smells_count > 0 
          output_smells_total(view)  
          view.report_smells
        else
          view.report_success
        end
      end

      private

      def output_smells_total(view)
        total_smells_message = "#{@total_smells_count} total warning"
        total_smells_message += 's' unless @total_smells_count <= 1  
        view.output total_smells_message 
      end
    end
  end
end
