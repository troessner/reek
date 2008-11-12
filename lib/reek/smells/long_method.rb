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

      MAX_ALLOWED = 5

      def self.examine(method, report)
        return if method.name == 'initialize'
        num = method.num_statements
        report << new(method, num) if num > MAX_ALLOWED
      end

      def initialize(context, num)
        super(context)
        @num_stmts = num
      end

      def detailed_report
        "#{@context} has approx #{@num_stmts} statements"
      end
    end

  end
end
