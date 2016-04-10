# frozen_string_literal: true
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

      def initialize(smell_type_or_class,
                     details: {},
                     configuration: Configuration::AppConfiguration.default)
        @smell_type = normalize smell_type_or_class
        @details  = details
        @configuration  = configuration
      end

      def matches?(source)
        self.examiner = Examiner.new(source, configuration: configuration)
        set_failure_messages
        matching_smell_types? && matching_details?
      end

      private

      attr_reader :configuration, :smell_type, :details
      attr_writer :failure_message, :failure_message_when_negated
      attr_accessor :examiner

      def set_failure_messages
        # We set the failure messages for non-matching smell type unconditionally since we
        # need that in any case for "failure_message_when_negated" below.
        # Depending on the existence of matching smell type we check for matching
        # smell details and then overwrite our failure messages conditionally.
        set_failure_messages_for_smell_type
        set_failure_messages_for_details if matching_smell_types? && !matching_details?
      end

      def matching_smell_types
        @matching_smell_types ||= smell_matchers.
          select { |it| it.matches_smell_type?(smell_type) }
      end

      def smell_matchers
        examiner.smells.map { |it| SmellMatcher.new(it) }
      end

      def matching_smell_types?
        matching_smell_types.any?
      end

      def matching_details?
        matching_smell_types.any? { |warning| warning.matches_attributes?(details) }
      end

      def set_failure_messages_for_smell_type
        self.failure_message = "Expected #{origin} to reek of #{smell_type}, "\
          'but it didn\'t'
        self.failure_message_when_negated = "Expected #{origin} not to reek "\
          "of #{smell_type}, but it did"
      end

      def set_failure_messages_for_details
        self.failure_message = "Expected #{origin} to reek of #{smell_type} "\
          "(which it did) with smell details #{details}, which it didn't"
        self.failure_message_when_negated = "Expected #{origin} not to reek of "\
          "#{smell_type} with smell details #{details}, but it did"
      end

      def origin
        examiner.description
      end

      # :reek:UtilityFunction
      def normalize(smell_type_or_class)
        case smell_type_or_class
        when Class
          smell_type_or_class.smell_type
        else
          smell_type_or_class.to_s
        end
      end
    end
  end
end
