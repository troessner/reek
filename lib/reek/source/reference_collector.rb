
module Reek
  module Source
    #
    # Locates references to the current object within a portion
    # of an abstract syntax tree.
    #
    class ReferenceCollector
      STOP_NODES = [:class, :module, :def, :defs]

      def initialize(ast)
        @ast = ast
      end

      def num_refs_to_self
        result = 0
        [:self, :zsuper, :ivar, :ivasgn].each do |node_type|
          @ast.look_for(node_type, STOP_NODES) { result += 1 }
        end
        @ast.look_for(:send, STOP_NODES) do |call|
          result += 1 unless call.receiver
        end
        result
      end
    end
  end
end
