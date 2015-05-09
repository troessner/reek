require_relative 'smell_detector'

module Reek
  module Smells
    #
    # A Long Method is any method that has a large number of lines.
    #
    # +TooManyStatements+ reports any method with more than 5 statements.
    #
    # See docs/Too-Many-Statements for details.
    class TooManyStatements < SmellDetector
      # The name of the config field that sets the maximum number of
      # statements permitted in any method.
      MAX_ALLOWED_STATEMENTS_KEY = 'max_statements'
      DEFAULT_MAX_STATEMENTS = 5

      def self.smell_category
        'LongMethod'
      end

      def self.default_config
        super.merge(
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
        @max_allowed_statements = value(MAX_ALLOWED_STATEMENTS_KEY,
                                        ctx,
                                        DEFAULT_MAX_STATEMENTS)
        count = ctx.num_statements
        return [] if count <= @max_allowed_statements
        [SmellWarning.new(self,
                          context: ctx.full_name,
                          lines: [ctx.exp.line],
                          message: "has approx #{count} statements",
                          parameters: { count: count })]
      end
    end
  end
end
