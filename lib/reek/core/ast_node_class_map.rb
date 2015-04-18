require_relative 'ast_node'
require_relative '../sexp/sexp_node'
require_relative '../sexp/sexp_extensions'

module Reek
  module Core
    # Maps AST node types to sublasses of ASTNode extended with the relevant
    # utility modules.
    class ASTNodeClassMap
      def initialize
        @klass_map = {}
      end

      def klass_for(type)
        @klass_map[type] ||=
          begin
            klass = Class.new(ASTNode)
            klass.send :include, extension_map[type] if extension_map[type]
            klass.send :include, Sexp::SexpNode
          end
      end

      def extension_map
        @extension_map ||=
          begin
            assoc = Sexp::SexpExtensions.constants.map do |const|
              [
                const.to_s.sub(/Node$/, '').downcase.to_sym,
                Sexp::SexpExtensions.const_get(const)
              ]
            end
            Hash[assoc]
          end
      end
    end
  end
end
