require 'reek/examiner'
require 'reek/cli/report/report'
require 'reek/cli/report/formatter'
require 'reek/cli/report/strategy'

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

      def failure_message
        "Expected #{@examiner.description} to reek, but it didn't"
      end

      def failure_message_when_negated
        rpt = Cli::Report::Formatter.format_list(@examiner.smells)
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
