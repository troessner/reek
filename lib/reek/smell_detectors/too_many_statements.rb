# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # A Long Method is any method that has a large number of lines.
    #
    # +TooManyStatements+ reports any method with more than 5 statements.
    #
    # See {file:docs/Too-Many-Statements.md} for details.
    class TooManyStatements < BaseDetector
      # The name of the config field that sets the maximum number of
      # statements permitted in any method.
      MAX_ALLOWED_STATEMENTS_KEY = 'max_statements'.freeze
      DEFAULT_MAX_STATEMENTS = 5

      def self.default_config
        super.merge(
          MAX_ALLOWED_STATEMENTS_KEY => DEFAULT_MAX_STATEMENTS,
          EXCLUDE_KEY => ['initialize'])
      end

      #
      # Checks the length of the given +method+.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(ctx)
        max_allowed_statements = value(MAX_ALLOWED_STATEMENTS_KEY, ctx)
        count = ctx.number_of_statements
        return [] if count <= max_allowed_statements
        [smell_warning(
          context: ctx,
          lines: [ctx.exp.line],
          message: "has approx #{count} statements",
          parameters: { count: count })]
      end
    end
  end
end
