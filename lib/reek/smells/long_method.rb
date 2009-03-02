require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # A Long Method is any method that has a large number of lines.
    #
    # Currently +LongMethod+ reports any method with more than
    # 5 statements.
    #
    class LongMethod < SmellDetector

      MAX_ALLOWED_STATEMENTS_KEY = 'max_statements'

      def self.default_config
        super.adopt(
          MAX_ALLOWED_STATEMENTS_KEY => 5,
          'exceptions' => ['initialize']
        )
      end

      def initialize(config = LongMethod.default_config)
        super
        @max_statements = config[MAX_ALLOWED_STATEMENTS_KEY]
      end

      #
      # Checks the length of the given +method+.
      # Any smells found are added to the +report+.
      #
      def examine_context(method, report)
        num = method.num_statements
        return false if num <= @max_statements
        report << SmellWarning.new(smell_name, method,
                    "has approx #{num} statements")
      end
    end
  end
end
