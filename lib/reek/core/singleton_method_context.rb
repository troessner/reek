require 'reek/core/method_context'

module Reek
  module Core
    #
    # A context wrapper for any singleton method definition found in a syntax tree.
    #
    class SingletonMethodContext < MethodContext
      def initialize(outer, exp)
        super(outer, exp)
      end

      def envious_receivers
        []
      end
    end
  end
end
