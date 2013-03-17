require 'reek/examiner'
require 'reek/cli/report'

module Reek
  module Spec

    #
    # An rspec matcher that matches when the +actual+ has code smells.
    #
    class ShouldReek        # :nodoc:
      def initialize(config_files = [])
        @config_files = config_files
      end
      def matches?(actual)
        @examiner = Examiner.new(actual, @config_files)
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
      ShouldReek.new(Dir['config/*.reek'])
    end
  end
end
