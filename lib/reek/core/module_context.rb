require 'reek/core/code_context'
require 'reek/core/code_parser'
require 'reek/core/sniffer'
require 'reek/source/sexp_formatter'

module Reek
  module Core

    #
    # A context wrapper for any module found in a syntax tree.
    #
    class ModuleContext < CodeContext

      def initialize(outer, exp)
        super(outer, exp)
        @name = Source::SexpFormatter.format(exp[1])
      end
    end
  end
end
