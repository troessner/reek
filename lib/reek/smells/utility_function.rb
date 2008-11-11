$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    class UtilityFunction < Smell
      def initialize(context, num_stmts)
        super
        @num_stmts = num_stmts
      end

      def recognise?(depends_on_self)
        @num_stmts > 0 and !depends_on_self
      end

      def detailed_report
        "#{@context} doesn't depend on instance state"
      end
    end

  end
end
