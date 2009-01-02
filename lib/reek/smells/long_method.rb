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

      @@max_statements = 5

      #
      # Checks the length of the given +method+.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine_context(method, report)
        num = method.num_statements
        return false if method.constructor? or num <= @@max_statements
        report << LongMethodReport.new(method, num)
      end

      def self.set_default_values(hash)      # :nodoc:
        update(:max_statements, hash)
      end
    end

    class LongMethodReport < SmellDetector

      def initialize(context, num)
        super(context)
        @num_stmts = num
      end

      def detailed_report
        "#{@context.to_s} has approx #{@num_stmts} statements"
      end
    end
  end
end
