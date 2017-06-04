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
      include RSpec::Matchers::Composable

      attr_reader :failure_message, :failure_message_when_negated

      def initialize(smell_type_or_class,
                     smell_details = {},
                     configuration = Configuration::AppConfiguration.default)
        @smell_type = normalize smell_type_or_class
        @smell_details = smell_details
        configuration.load_values(smell_type => { SmellConfiguration::ENABLED_KEY => true })
        @configuration = configuration
      end

      def matches?(source)
        @matching_smell_types = nil
        self.examiner = Examiner.new(source,
                                     filter_by_smells: [smell_type],
                                     configuration: configuration)
        set_failure_messages
        matching_smell_details?
      end

      def with_config(config_hash)
        new_configuration = Configuration::AppConfiguration.default
        new_configuration.load_values(smell_type => config_hash)
        self.class.new(smell_type, smell_details, new_configuration)
      end

      private

      attr_reader :configuration, :smell_type, :smell_details
      attr_writer :failure_message, :failure_message_when_negated
      attr_accessor :examiner

      def set_failure_messages
        # We set the failure messages for non-matching smell type unconditionally since we
        # need that in any case for "failure_message_when_negated" below.
        # Depending on the existence of matching smell type we check for matching
        # smell details and then overwrite our failure messages conditionally.
        set_failure_messages_for_smell_type
        set_failure_messages_for_smell_details if matching_smell_types? && !matching_smell_details?
      end

      def matching_smell_types
        @matching_smell_types ||= examiner.smells.map { |it| SmellMatcher.new(it) }
      end

      def matching_smell_types?
        matching_smell_types.any?
      end

      def matching_smell_details?
        matching_smell_types.any? { |warning| warning.matches_attributes?(smell_details) }
      end

      def set_failure_messages_for_smell_type
        self.failure_message = "Expected #{origin} to reek of #{smell_type}, "\
          'but it didn\'t'
        self.failure_message_when_negated = "Expected #{origin} not to reek "\
          "of #{smell_type}, but it did"
      end

      def set_failure_messages_for_smell_details
        self.failure_message = "Expected #{origin} to reek of #{smell_type} "\
          "(which it did) with smell details #{smell_details}, which it didn't.\n"\
          "The number of smell details I had to compare with the given one was #{matching_smell_types.count} "\
          "and here they are:\n"\
          "#{all_relevant_smell_details_formatted}"
        self.failure_message_when_negated = "Expected #{origin} not to reek of "\
          "#{smell_type} with smell details #{smell_details}, but it did"
      end

      # :reek:FeatureEnvy
      def all_relevant_smell_details_formatted
        matching_smell_types.each_with_object([]).with_index do |(smell, accumulator), index|
          accumulator << "#{index + 1}.)\n"
          warning_as_hash = smell.smell_warning.to_hash
          warning_as_hash.delete('smell_type')
          accumulator << "#{warning_as_hash}\n"
        end.join
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
