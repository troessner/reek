# frozen_string_literal: true

require_relative 'ast/ast_node_class_map'

module Reek
  #
  # Adorns an abstract syntax tree with mix-in modules to make accessing
  # the tree more understandable and less implementation-dependent.
  #
  class TreeDresser
    def initialize(klass_map: AST::ASTNodeClassMap.new)
      @klass_map = klass_map
    end

    # Recursively enhance an AST with type-dependent mixins, and comments.
    #
    # See {file:docs/How-reek-works-internally.md} for the big picture of how this works.
    # Example:
    # This
    #   class Klazz; def meth(argument); argument.call_me; end; end
    # corresponds to this sexp:
    #   (class
    #     (const nil :Klazz) nil
    #     (def :meth
    #       (args
    #         (arg :argument))
    #       (send
    #         (lvar :argument) :call_me)))
    # where every node is of type Parser::AST::Node.
    # Passing this into `dress` will return the exact same structure, but this
    # time the nodes will contain type-dependent mixins, e.g. this:
    #   (const nil :Klazz)
    #  will be of type Reek::AST::Node with  Reek::AST::SexpExtensions::ConstNode mixed in.
    # @param sexp [Parser::AST::Node] - the given sexp
    # @param comment_map [Hash] - see the documentation for SourceCode#syntax_tree
    # @param parent [Parser::AST::Node] - the parent sexp
    #
    # @return an instance of Reek::AST::Node with type-dependent sexp extensions mixed in.
    #
    # :reek:FeatureEnvy
    # :reek:TooManyStatements: { max_statements: 6 }
    def dress(sexp, comment_map)
      return sexp unless sexp.is_a? ::Parser::AST::Node
      type = sexp.type
      children = sexp.children.map { |child| dress(child, comment_map) }
      comments = comment_map[sexp]
      klass_map.klass_for(type).new(type, children,
                                    location: sexp.loc, comments: comments)
    end

    private

    attr_reader :klass_map
  end
end
