require 'reek/source/sexp_node'
require 'reek/source/sexp_extensions'

module Reek
  module Source
    #
    # Adorns an abstract syntax tree with mix-in modules to make accessing
    # the tree more understandable and less implementation-dependent.
    #
    class TreeDresser
      def initialize(extensions_module = SexpExtensions, node_module = SexpNode)
        @extensions_module = extensions_module
        @node_module = node_module
      end

      def dress(sexp)
        extend_sexp(sexp)
        sexp.each_sexp { |sub| dress(sub) }
        sexp
      end

      private

      def extend_sexp(sexp)
        sexp.extend(@node_module)
        extension_module = extension_for(sexp)
        sexp.extend(extension_module) if extension_module
      end

      def extension_for(sexp)
        extension_map[sexp.sexp_type]
      end

      def extension_map
        @extension_map ||= begin
                             assoc = @extensions_module.constants.map { |const|
                               [
                                 const.to_s.sub(/Node$/, '').downcase.to_sym,
                                 @extensions_module.const_get(const)
                               ]
                             }
                             Hash[assoc]
                           end
      end
    end
  end
end
