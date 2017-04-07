# frozen_string_literal: true

module Reek
  module Spec
    #
    # Matches a +SmellWarning+ object agains a smell type and hash of attributes.
    #
    class SmellMatcher
      attr_reader :smell_warning

      COMPARABLE_ATTRIBUTES = [:message, :lines, :context, :source].freeze

      def initialize(smell_warning)
        @smell_warning = smell_warning
      end

      def matches?(klass, attributes = {})
        matches_smell_type?(klass) && matches_attributes?(attributes)
      end

      def matches_smell_type?(klass)
        smell_warning.smell_type == klass.to_s
      end

      def matches_attributes?(attributes)
        check_attributes_comparability(attributes)

        fields, params = attributes.
          partition { |key, _| COMPARABLE_ATTRIBUTES.include? key }.
          map(&:to_h)

        common_parameters_equal?(params) &&
          common_attributes_equal?(fields)
      end

      private

      def check_attributes_comparability(other_attributes)
        parameter_keys = other_attributes.keys - COMPARABLE_ATTRIBUTES
        extra_keys = parameter_keys - smell_warning.parameters.keys
        return if extra_keys.empty?
        raise ArgumentError, "The attribute '#{extra_keys.first}' is not available for comparison"
      end

      def common_parameters_equal?(other_parameters)
        smell_warning.parameters.slice(*other_parameters.keys) == other_parameters
      end

      def common_attributes_equal?(attributes)
        attributes.all? do |other_key, other_value|
          smell_warning.send(other_key) == other_value
        end
      end
    end
  end
end
