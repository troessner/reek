$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    #
    # A Long Method is any method that has a large number of lines.
    #
    # Currently +LongMethod+ reports any method with more than
    # +MAX_ALLOWED+ statements.
    #
    class LongMethod < Smell

      MAX_STATEMENTS_KEY = 'max_statements'

      #
      # Checks the length of the given +method+.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine_context(method, report)
        num = method.num_statements
        return false if method.constructor? or num <= config[MAX_STATEMENTS_KEY]
        report << new(method, num)
      end

      def self.set_default_values(hash)      # :nodoc:
        hash[MAX_STATEMENTS_KEY] = 5
      end

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
