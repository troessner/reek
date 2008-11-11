$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

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
