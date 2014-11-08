require 'reek/source/ast_node_class_map'

module Reek
  module Source
    #
    # Adorns an abstract syntax tree with mix-in modules to make accessing
    # the tree more understandable and less implementation-dependent.
    #
    class TreeDresser
      def initialize(klass_map = AstNodeClassMap.new)
        @klass_map = klass_map
      end

      def dress(sexp, comment_map)
        return sexp unless sexp.is_a? AST::Node
        type = sexp.type
        children = sexp.children.map { |child| dress(child, comment_map) }
        comments = comment_map[sexp]
        @klass_map.klass_for(type).new(type, children,
                                       location: sexp.loc, comments: comments)
      end
    end
  end
end
