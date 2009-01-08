$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # A Long Method is any method that has a large number of lines.
    #
    # Currently +LongMethod+ reports any method with more than
    # +MAX_ALLOWED+ statements.
    #
    class LongMethod < SmellDetector

      def initialize(config = {})
        super
        @max_statements = config.fetch('max_calls', 5)
      end

      #
      # Checks the length of the given +method+.
      # Any smells found are added to the +report+.
      #
      def examine_context(method, report)
        num = method.num_statements
        return false if method.constructor? or num <= @max_statements
        report << SmellWarning.new(smell_name, method,
                    "has approx #{num} statements")
      end
    end
  end
end
