require_relative 'code_context'
require_relative '../sexp/sexp_formatter'

module Reek
  module Core
    #
    # A context wrapper for any module found in a syntax tree.
    #
    class ModuleContext < CodeContext
      def initialize(outer, exp)
        super(outer, exp)
        @name = Sexp::SexpFormatter.format(exp.children.first)
      end

      def node_instance_methods
        local_nodes(:def)
      end
    end
  end
end
