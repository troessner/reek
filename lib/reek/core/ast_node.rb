require 'parser'

module Reek
  module Core
    # Base class for AST nodes extended with utility methods. Contains some
    # methods to ease the transition from Sexp to AST::Node.
    class ASTNode < Parser::AST::Node
      def initialize(type, children = [], options = {})
        @comments = options.fetch(:comments, [])
        super
      end

      def comments
        @comments.map(&:text).join("\n")
      end

      # @deprecated
      def [](index)
        elements[index]
      end

      def line
        loc.line
      end

      # @deprecated
      def first
        type
      end

      private

      def elements
        [type, *children]
      end
    end
  end
end
