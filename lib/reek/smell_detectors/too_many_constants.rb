# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods, constants or lines of code.
    #
    # +TooManyConstants' reports classes having more than a
    # configurable number of constants.
    #
    # See {file:docs/Too-Many-Constants.md} for details.
    class TooManyConstants < BaseDetector
      # The name of the config field that sets the maximum number
      # of constants permitted in a class.
      MAX_ALLOWED_CONSTANTS_KEY = 'max_constants'.freeze
      DEFAULT_MAX_CONSTANTS = 5
      IGNORED_NODES = [:module, :class].freeze

      def self.contexts
        [:class, :module]
      end

      def self.default_config
        super.merge(
          MAX_ALLOWED_CONSTANTS_KEY => DEFAULT_MAX_CONSTANTS,
          EXCLUDE_KEY => [])
      end

      #
      # Checks +klass+ for too many constants.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        count = context.each_node(:casgn, IGNORED_NODES).delete_if(&:defines_module?).length

        return [] if count <= max_allowed_constants

        build_smell_warning(count)
      end

      private

      def max_allowed_constants
        value(MAX_ALLOWED_CONSTANTS_KEY, context)
      end

      def build_smell_warning(count)
        [smell_warning(
          context: context,
          lines: [source_line],
          message: "has #{count} constants",
          parameters: { count: count })]
      end
    end
  end
end
