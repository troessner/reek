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
    # Currently +UncommunicativeModuleName+ checks for
    # * 1-character names
    # * names ending with a number
    #
    # See {file:docs/Uncommunicative-Module-Name.md} for details.
    class UncommunicativeModuleName < BaseDetector
      # The name of the config field that lists the regexps of
      # smelly names to be reported.
      REJECT_KEY = 'reject'.freeze
      DEFAULT_REJECT_PATTERNS = [/^.$/, /[0-9]$/].freeze

      # The name of the config field that lists the specific names that are
      # to be treated as exceptions; these names will not be reported as
      # uncommunicative.
      ACCEPT_KEY = 'accept'.freeze
      DEFAULT_ACCEPT_PATTERNS = [].freeze

      def self.default_config
        super().merge(
          REJECT_KEY => DEFAULT_REJECT_PATTERNS,
          ACCEPT_KEY => DEFAULT_ACCEPT_PATTERNS)
      end

      def self.contexts
        [:module, :class]
      end

      #
      # Checks the given +context+ for uncommunicative names.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(context)
        fully_qualified_name = context.full_name
        exp                  = context.exp
        module_name          = exp.simple_name

        return [] if acceptable_name?(context: context,
                                      module_name: module_name,
                                      fully_qualified_name: fully_qualified_name)

        [smell_warning(
          context: context,
          lines: [exp.line],
          message: "has the name '#{module_name}'",
          parameters: { name: module_name })]
      end

      private

      # :reek:ControlParameter
      def acceptable_name?(context:, module_name:, fully_qualified_name:)
        accept_patterns(context).any? { |accept_pattern| fully_qualified_name.match accept_pattern } ||
          reject_patterns(context).none? { |reject_pattern| module_name.match reject_pattern }
      end

      def reject_patterns(context)
        Array value(REJECT_KEY, context)
      end

      def accept_patterns(context)
        Array value(ACCEPT_KEY, context)
      end
    end
  end
end
