require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'examiner')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'cli', 'report')

module Reek
  module Spec

    #
    # An rspec matcher that matches when the +actual+ has code smells.
    #
    class ShouldReek        # :nodoc:
      def matches?(actual)
        @examiner = Examiner.new(actual)
        @examiner.smelly?
      end
      def failure_message_for_should
        "Expected #{@examiner.description} to reek, but it didn't"
      end
      def failure_message_for_should_not
        rpt = Cli::ReportFormatter.format_list(@examiner.smells)
        "Expected no smells, but got:\n#{rpt}"
      end
    end

    #
    # Returns +true+ if and only if the target source code contains smells.
    #
    def reek
      ShouldReek.new
    end
  end
end
