require_relative '../examiner'
require_relative '../report/formatter'

module Reek
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has the specified
    # code smell and no others.
    #
    # @api private
    class ShouldReekOnlyOf < ShouldReekOf
      def matches?(actual)
        matches_examiner?(Examiner.new(actual, configuration: configuration))
      end

      def matches_examiner?(examiner)
        self.examiner = examiner
        self.warnings = examiner.smells
        return false if warnings.empty?
        warnings.all? { |warning| warning.matches?(smell_category) }
      end

      def failure_message
        rpt = Report::Formatter.format_list(warnings)
        "Expected #{examiner.description} to reek only of #{smell_category}, but got:\n#{rpt}"
      end

      def failure_message_when_negated
        "Expected #{examiner.description} not to reek only of #{smell_category}, but it did"
      end

      private

      private_attr_accessor :warnings
    end
  end
end
