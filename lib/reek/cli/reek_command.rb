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

      def execute(app)
        @sources.each do |source|
          @reporter.add_examiner(Examiner.new(source, @config_files))
        end
        app.update_status(@reporter)
        @reporter.show
      end
    end
  end
end
