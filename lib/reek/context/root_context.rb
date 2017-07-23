# frozen_string_literal: true

require_relative 'code_context'
require_relative 'method_context'

module Reek
  module Context
    #
    # A context wrapper representing the root of an abstract syntax tree.
    #
    class RootContext < CodeContext
      def type
        :root
      end

      def full_name
        ''
      end

      # Return the correct class for child method contexts (representing nodes
      # of type `:def`). For RootContext, this is the class that represents
      # instance methods.
      def method_context_class
        MethodContext
      end
    end
  end
end
