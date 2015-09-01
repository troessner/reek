require_relative 'code_context'

module Reek
  module Context
    #
    # A context wrapper representing the root of an abstract syntax tree.
    #
    class RootContext < CodeContext
      def initialize(exp)
        super(nil, exp)
      end

      def type
        :root
      end

      def full_name
        ''
      end
    end
  end
end
