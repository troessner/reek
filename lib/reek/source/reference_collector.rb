
module Reek
  module Source
    class ReferenceCollector
      def initialize(ast)
        @ast = ast
      end

      def num_refs_to_self
        result = 0
        [:self, :zsuper, :ivar, :iasgn].each do |node_type|
          @ast.look_for(node_type, [:class, :module, :defn, :defs]) { result += 1}
        end
        @ast.look_for(:call, [:class, :module, :defn, :defs]) do |call|
          result += 1 unless call.receiver
        end
        result
      end
    end
  end
end
