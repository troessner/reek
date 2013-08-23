require 'sexp_dresser/core/code_context'
require 'sexp_dresser/core/code_parser'
# require 'sexp_dresser/core/sniffer'
require 'sexp_dresser/source/sexp_formatter'

module SexpDresser
  module Core

    #
    # A context wrapper for any module found in a syntax tree.
    #
    class ModuleContext < CodeContext

      def initialize(outer, name, exp)
        super(outer, exp)
        @name = name
      end
    end
  end
end
