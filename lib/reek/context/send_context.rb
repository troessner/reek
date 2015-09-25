require_relative 'code_context'

module Reek
  module Context
    #
    # A context wrapper for method calls found in a syntax tree.
    #
    class SendContext < CodeContext
      attr_reader :name

      def initialize(context, exp, name)
        @name = name
        super context, exp
      end
    end
  end
end
