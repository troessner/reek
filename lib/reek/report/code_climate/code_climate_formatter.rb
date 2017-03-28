# frozen_string_literal: true

require 'codeclimate_engine'
require_relative 'code_climate_configuration'

module Reek
  module Report
    # Generates a hash in the structure specified by the Code Climate engine spec
    class CodeClimateFormatter
      def initialize(warning)
        @warning = warning
      end

      def render
        CCEngine::Issue.new(check_name: check_name,
                            description: description,
                            categories: categories,
                            location: location,
                            remediation_points: remediation_points,
                            fingerprint: fingerprint,
                            content: content).render
      end

      private

      attr_reader :warning

      def description
        [warning.context, warning.message].join(' ')
      end

      def check_name
        warning.smell_type
      end

      def categories
        ['Complexity']
      end

      def location
        warning_lines = warning.lines
        CCEngine::Location::LineRange.new(
          path: warning.source,
          line_range: warning_lines.first..warning_lines.last)
      end

      def remediation_points
        configuration[warning.smell_type].fetch('remediation_points')
      end

      def fingerprint
        CodeClimateFingerprint.new(warning).compute
      end

      def content
        configuration[warning.smell_type].fetch('content')
      end

      def configuration
        @configuration ||= begin
          CodeClimateConfiguration.load
        end
      end
    end
  end
end
