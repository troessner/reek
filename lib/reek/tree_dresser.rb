require_relative 'ast/ast_node_class_map'

module Reek
  #
  # Adorns an abstract syntax tree with mix-in modules to make accessing
  # the tree more understandable and less implementation-dependent.
  #
  # @api private
  class TreeDresser
    def initialize(klass_map = AST::ASTNodeClassMap.new)
      @klass_map = klass_map
    end

    # Recursively enhance an AST with type-dependent mixins, and comments.
    #
    # See {file:docs/How-reek-works-internally.md} for the big picture of how this works.
    #
    # @param sexp [Parser::AST::Node] - the given sexp
    # @param comment_map [Hash] - see the documentation for SourceCode#syntax_tree
    # @param parent [Parser::AST::Node] - the parent sexp
    #
    # @return an instance of Reek::AST::Node with type-dependent sexp extensions mixed in.
    def dress(sexp, comment_map, parent = nil)
      return sexp unless sexp.is_a? ::Parser::AST::Node
      type = sexp.type
      children = sexp.children.map { |child| dress(child, comment_map, sexp) }
      comments = comment_map[sexp]
      klass_map.klass_for(type).new(type, children,
                                    location: sexp.loc, comments: comments, parent: parent)
    end

    private

    private_attr_reader :klass_map
  end
end
