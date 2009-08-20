require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    #
    # A Long Method is any method that has a large number of lines.
    #
    # Currently +LongMethod+ reports any method with more than
    # 5 statements.
    #
    class LongMethod < SmellDetector

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

      attr_reader :max_statements

      def initialize(config = LongMethod.default_config)
        super(config)
      end

      #
      # Checks the length of the given +method+.
      # Remembers any smells found.
      #
      def examine_context(method)
        num = method.num_statements
        return false if num <= value(MAX_ALLOWED_STATEMENTS_KEY, method, DEFAULT_MAX_STATEMENTS)
        found(method, "has approx #{num} statements")
      end
    end
  end
end
