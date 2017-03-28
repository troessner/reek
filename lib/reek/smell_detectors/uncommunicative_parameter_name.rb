# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # An Uncommunicative Name is a name that doesn't communicate its intent
    # well enough.
    #
    # Poor names make it hard for the reader to build a mental picture
    # of what's going on in the code. They can also be mis-interpreted;
    # and they hurt the flow of reading, because the reader must slow
    # down to interpret the names.
    #
    # Currently +UncommunicativeParameterName+ checks for
    # * 1-character names
    # * names ending with a number
    # * names beginning with an underscore
    # * names containing a capital letter (assuming camelCase)
    #
    # See {file:docs/Uncommunicative-Parameter-Name.md} for details.
    class UncommunicativeParameterName < BaseDetector
      REJECT_KEY = 'reject'.freeze
      DEFAULT_REJECT_PATTERNS = [/^.$/, /[0-9]$/, /[A-Z]/, /^_/].freeze

      ACCEPT_KEY = 'accept'.freeze
      DEFAULT_ACCEPT_PATTERNS = [].freeze

      def self.default_config
        super.merge(
          REJECT_KEY => DEFAULT_REJECT_PATTERNS,
          ACCEPT_KEY => DEFAULT_ACCEPT_PATTERNS)
      end

      #
      # Checks the given +context+ for uncommunicative names.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(context)
        expression = context.exp
        expression.parameter_names.select do |name|
          sanitized_name = sanitize name
          uncommunicative_parameter_name?(name: sanitized_name, context: context)
        end.map do |name|
          smell_warning(
            context: context,
            lines: [expression.line],
            message: "has the parameter name '#{name}'",
            parameters: { name: name.to_s })
        end
      end

      private

      def uncommunicative_parameter_name?(name:, context:)
        !acceptable_name?(name: name, context: context) && context.uses_param?(name)
      end

      def acceptable_name?(name:, context:)
        accept_patterns(context).any? { |accept_pattern| name.match accept_pattern } ||
          reject_patterns(context).none? { |reject_pattern| name.match reject_pattern }
      end

      def reject_patterns(context)
        Array value(REJECT_KEY, context)
      end

      def accept_patterns(context)
        Array value(ACCEPT_KEY, context)
      end

      # :reek:UtilityFunction
      def sanitize(name)
        name.to_s.gsub(/^[@\*\&]*/, '')
      end
    end
  end
end
