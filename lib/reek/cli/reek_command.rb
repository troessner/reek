require_relative 'command'
require_relative '../core/examiner'

module Reek
  module CLI
    #
    # A command to collect smells from a set of sources and write them out in
    # text report format.
    #
    class ReekCommand < Command
      def execute(app)
        @options.sources.each do |source|
          reporter.add_examiner Core::Examiner.new(source, smell_names)
        end
        reporter.smells? ? app.report_smells : app.report_success
        reporter.show
      end

      private

      def reporter
        @reporter ||= @options.reporter
      end

      def smell_names
        @smell_names ||= @options.smells_to_detect
      end
    end
  end
end
