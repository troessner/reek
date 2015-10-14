require_relative '../examiner'
require_relative 'smell_matcher'

module Reek
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has the specified
    # code smell.
    #
    class ShouldReekOf
      attr_reader :failure_message, :failure_message_when_negated

      private_attr_reader :configuration, :smell_category, :smell_details
      private_attr_writer :failure_message, :failure_message_when_negated
      private_attr_accessor :examiner

      def initialize(smell_category,
                     smell_details = {},
                     configuration = Configuration::AppConfiguration.default)
        @smell_category = normalize smell_category
        @smell_details  = smell_details
        @configuration  = configuration
      end

      def matches?(actual)
        self.examiner = Examiner.new(actual, configuration: configuration)
        set_failure_messages
        matching_smell_types? && matching_smell_details?
      end

      private

      def set_failure_messages
        # We set the failure messages for non-matching smell type unconditionally since we
        # need that in any case for "failure_message_when_negated" below.
        # Depending on the existence of matching smell type we check for matching
        # smell details and then overwrite our failure messages conditionally.
        set_failure_messages_for_smell_type
        set_failure_messages_for_smell_details if matching_smell_types? && !matching_smell_details?
      end

      def matching_smell_types
        @matching_smell_types ||= smell_matchers.
          select { |it| it.matches_smell_type?(smell_category) }
      end

      def smell_matchers
        examiner.smells.map { |it| SmellMatcher.new(it) }
      end

      def matching_smell_types?
        matching_smell_types.any?
      end

      def matching_smell_details?
        matching_smell_types.any? { |warning| warning.matches_attributes?(smell_details) }
      end

      def set_failure_messages_for_smell_type
        self.failure_message = "Expected #{origin} to reek of #{smell_category}, "\
          'but it didn\'t'
        self.failure_message_when_negated = "Expected #{origin} not to reek "\
          "of #{smell_category}, but it did"
      end

      def set_failure_messages_for_smell_details
        self.failure_message = "Expected #{origin} to reek of #{smell_category} "\
          "(which it did) with smell details #{smell_details}, which it didn't"
        self.failure_message_when_negated = "Expected #{origin} not to reek of "\
          "#{smell_category} with smell details #{smell_details}, but it did"
      end

      def origin
        examiner.description
      end

      # :reek:UtilityFunction
      def normalize(smell_category_or_type)
        # In theory, users can give us many different types of input (see the documentation for
        # reek_of below), however we're basically ignoring all of those subleties and just
        # return a string with the prepending namespace stripped.
        smell_category_or_type.to_s.split(/::/)[-1]
      end
    end
  end
end
