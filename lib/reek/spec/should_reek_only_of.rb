require 'reek/examiner'
require 'reek/cli/report/formatter'

module Reek
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has the specified
    # code smell and no others.
    #
    class ShouldReekOnlyOf < ShouldReekOf
      def matches?(actual)
        matches_examiner?(Examiner.new(actual))
      end

      def matches_examiner?(examiner)
        @examiner = examiner
        @warnings = @examiner.smells
        return false if @warnings.empty?
        @warnings.all? { |warning| warning.matches?(@smell_category) }
      end

      def failure_message
        rpt = Cli::Report::Formatter.format_list(@warnings)
        "Expected #{@examiner.description} to reek only of #{@smell_category}, but got:\n#{rpt}"
      end

      def failure_message_when_negated
        "Expected #{@examiner.description} not to reek only of #{@smell_category}, but it did"
      end
    end

    #
    # See the documentaton for "reek_of".
    #
    # Notable differences to reek_of:
    #   1.) "reek_of" doesn't mind if there are other smells of a different category.
    #       "reek_only_of" will fail in that case.
    #   2.) "reek_only_of" doesn't support the additional smell_details hash.
    def reek_only_of(smell_category)
      ShouldReekOnlyOf.new(smell_category)
    end
  end
end
