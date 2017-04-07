# frozen_string_literal: true

require 'digest'

module Reek
  module Report
    # Generates a string to uniquely identify a smell
    class CodeClimateFingerprint
      NON_IDENTIFYING_PARAMETERS = [:count, :depth].freeze

      def initialize(warning)
        @warning = warning
      end

      def compute
        return unless warning_uniquely_identifiable?

        identify_warning

        identifying_aspects.hexdigest.freeze
      end

      private

      attr_reader :warning

      def identify_warning
        identifying_aspects << warning.source
        identifying_aspects << warning.smell_type
        identifying_aspects << warning.context
        identifying_aspects << parameters
      end

      def identifying_aspects
        @identifying_aspects ||= Digest::MD5.new
      end

      def parameters
        warning.parameters.reject { |key, _| NON_IDENTIFYING_PARAMETERS.include?(key) }.sort.to_s
      end

      def warning_uniquely_identifiable?
        # These could be identifiable if they had parameters
        ![
          'ManualDispatch',
          'NilCheck'
        ].include?(warning.smell_type)
      end
    end
  end
end
