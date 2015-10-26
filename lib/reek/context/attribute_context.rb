require_relative 'code_context'

module Reek
  module Context
    #
    # A context wrapper for attribute definitions found in a syntax tree.
    #
    class AttributeContext < CodeContext
      def initialize(context, exp, send_expression)
        @send_expression = send_expression
        super context, exp
      end

      def full_comment
        send_expression.full_comment || ''
      end

      private_attr_reader :send_expression
    end
  end
end
