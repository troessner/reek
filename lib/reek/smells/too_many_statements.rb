require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    #
    # A Long Method is any method that has a large number of lines.
    #
    # +TooManyStatements+ reports any method with more than 5 statements.
    #
    class TooManyStatements < SmellDetector

      SMELL_CLASS = 'LongMethod'
      SMELL_SUBCLASS = self.name.split(/::/)[-1]

      STATEMENT_COUNT_KEY = 'statement_count'

      # The name of the config field that sets the maximum number of
      # statements permitted in any method.
      MAX_ALLOWED_STATEMENTS_KEY = 'max_statements'

      DEFAULT_MAX_STATEMENTS = 5

      def self.default_config
        super.adopt(
          MAX_ALLOWED_STATEMENTS_KEY => DEFAULT_MAX_STATEMENTS,
          EXCLUDE_KEY => ['initialize']
        )
      end

      #
      # Checks the length of the given +method+.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        @max_allowed_statements = value(MAX_ALLOWED_STATEMENTS_KEY, ctx, DEFAULT_MAX_STATEMENTS)
        num = ctx.num_statements
        return [] if num <= @max_allowed_statements
        smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, [ctx.exp.line],
          "has approx #{num} statements",
          @source, SMELL_SUBCLASS,
          {STATEMENT_COUNT_KEY => num})
        [smell]
      end
    end
  end
end
