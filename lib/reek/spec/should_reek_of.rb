require_relative '../core/examiner'

module Reek
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has the specified
    # code smell.
    #
    class ShouldReekOf
      def initialize(smell_category, smell_details = {})
        @smell_category = normalize smell_category
        @smell_details  = smell_details
      end

      def matches?(actual)
        @examiner = Core::Examiner.new(actual)
        @all_smells = @examiner.smells
        @all_smells.any? { |warning| warning.matches?(@smell_category, @smell_details) }
      end

      def failure_message
        "Expected #{@examiner.description} to reek of #{@smell_category}, but it didn't"
      end

      def failure_message_when_negated
        "Expected #{@examiner.description} not to reek of #{@smell_category}, but it did"
      end

      private

      def normalize(smell_category_or_type)
        # In theory, users can give us many different types of input (see the documentation for
        # reek_of below), however we're basically ignoring all of those subleties and just
        # return a string with the prepending namespace stripped.
        smell_category_or_type.to_s.split(/::/)[-1]
      end
    end
  end
end
