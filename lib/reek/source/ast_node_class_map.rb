require 'reek/source/ast_node'
require 'reek/source/sexp_node'
require 'reek/source/sexp_extensions'

module Reek
  module Source
    # Maps AST node types to sublasses of AstNode extended with the relevant
    # utility modules.
    class AstNodeClassMap
      def initialize
        @klass_map = {}
      end

      def klass_for(type)
        @klass_map[type] ||=
          begin
            klass = Class.new(AstNode)
            klass.send :include, extension_map[type] if extension_map[type]
            klass.send :include, SexpNode
          end
      end

      def extension_map
        @extension_map ||=
          begin
            assoc = SexpExtensions.constants.map do |const|
              [
                const.to_s.sub(/Node$/, '').downcase.to_sym,
                SexpExtensions.const_get(const)
              ]
            end
            Hash[assoc]
          end
      end
    end
  end
end
