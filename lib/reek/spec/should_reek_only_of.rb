require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'examiner')

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
        @all_smells = @examiner.smells
        @all_smells.length == 1 and @all_smells[0].matches?(@klass, @patterns)
      end
      def failure_message_for_should
        rpt = @all_smells.map { |smell| "#{smell.report('%c %w (%s)')}" }.join("\n")
        "Expected #{@examiner.description} to reek only of #{@klass}, but got:\n#{rpt}"
      end
      def failure_message_for_should_not
        "Expected #{@examiner.description} not to reek only of #{@klass}, but it did"
      end
    end

    #
    # As for reek_of, but the matched smell warning must be the only warning of
    # any kind in the target source code's Reek report.
    #
    def reek_only_of(smell_class, *patterns)
      ShouldReekOnlyOf.new(smell_class, patterns)
    end
  end
end
