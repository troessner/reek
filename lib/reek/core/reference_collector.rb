module Reek
  module Core
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
        (explicit_self_calls + implicit_self_calls).size
      end

      private

      def explicit_self_calls
        [:self, :zsuper, :ivar, :ivasgn].flat_map do |node_type|
          @ast.each_node(node_type, STOP_NODES)
        end
      end

      def implicit_self_calls
        @ast.each_node(:send, STOP_NODES).reject(&:receiver)
      end
    end
  end
end
