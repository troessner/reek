require 'reek/core/code_context'
require 'reek/source/sexp_formatter'

module Reek
  module Core
    #
    # A context wrapper for any module found in a syntax tree.
    #
    class ModuleContext < CodeContext
      def initialize(outer, exp)
        super(outer, exp)
        @name = Source::SexpFormatter.format(exp.children.first)
      end

      def node_instance_methods
        local_nodes(:def)
      end
    end
  end
end
