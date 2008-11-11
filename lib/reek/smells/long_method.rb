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

      def recognise?(num_stmts)
        @num_stmts = num_stmts
        num_stmts > MAX_ALLOWED
      end

      def detailed_report
        "#{@context} has approx #{@num_stmts} statements"
      end
    end

  end
end
