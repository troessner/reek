# frozen_string_literal: true

module Reek
  module AST
    #
    # Locates references to the current object within a portion
    # of an abstract syntax tree.
    #
    class ReferenceCollector
      def initialize(ast)
        @ast = ast
      end

      def num_refs_to_self
        (explicit_self_calls.to_a + implicit_self_calls.to_a).size
      end

      private

      attr_reader :ast

      def explicit_self_calls
        ast.each_node([:self, :super, :zsuper, :ivar, :ivasgn])
      end

      def implicit_self_calls
        ast.each_node(:send).reject(&:receiver)
      end
    end
  end
end
