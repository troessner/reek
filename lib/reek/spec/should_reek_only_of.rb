require 'reek/examiner'
require 'reek/cli/report/report'
require 'reek/cli/report/formatter'
require 'reek/cli/report/strategy'

module Reek
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has the specified
    # code smell and no others.
    #
    class ShouldReekOnlyOf < ShouldReekOf        # :nodoc:
      def matches?(actual)
        matches_examiner?(Examiner.new(actual))
      end

      def matches_examiner?(examiner)
        @examiner = examiner
        @warnings = @examiner.smells
        @warnings.length == 1 && @warnings[0].matches?(@klass, @patterns)
      end

      def failure_message
        rpt = Cli::Report::Formatter.format_list(@warnings)
        "Expected #{@examiner.description} to reek only of #{@klass}, but got:\n#{rpt}"
      end

      def failure_message_when_negated
        "Expected #{@examiner.description} not to reek only of #{@klass}, but it did"
      end
    end

    #
    # As for reek_of, but the matched smell warning must be the only warning of
    # any kind in the target source code's Reek report.
    #
    def reek_only_of(smell_category, *patterns)
      ShouldReekOnlyOf.new(smell_category, patterns)
    end
  end
end
