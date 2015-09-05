require_relative 'method_context'

module Reek
  module Context
    #
    # A context wrapper for any singleton method definition found in a syntax tree.
    #
    class SingletonMethodContext < MethodContext
      def envious_receivers
        {}
      end
    end
  end
end
