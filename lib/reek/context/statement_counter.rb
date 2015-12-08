require_relative '../ast/node'
require 'private_attr/everywhere'

module Reek
  module Context
    # Responsible for counting the statements in a `CodeContext`.
    class StatementCounter
      attr_reader :value
      private_attr_writer :value

      def initialize
        @value = 0
      end

      def increase_by(sexp)
        return unless sexp
        case sexp
        when Reek::AST::Node
          self.value = value + 1
        when Array
          self.value = value + sexp.length
        else
          raise ArgumentError, "Invalid type #{sexp} given"
        end
      end

      def decrease_by(number)
        self.value = value - number
      end
    end
  end
end
