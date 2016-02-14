require_relative 'command'
require_relative '../examiner'

module Reek
  module CLI
    #
    # A command to collect smells from a set of sources and write them out in
    # text report format.
    #
    class ReekCommand < Command
      def execute(app)
        options.sources.each do |source|
          reporter.add_examiner Examiner.new(source, smell_names, configuration: app.configuration)
        end
        reporter.show
        result_code
      end

      private

      def result_code
        reporter.smells? ? options.failure_exit_code : options.success_exit_code
      end

      def reporter
        @reporter ||= options.reporter
      end

      def smell_names
        @smell_names ||= options.smells_to_detect
      end
    end
  end
end
