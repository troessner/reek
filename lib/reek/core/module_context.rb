require File.join(File.dirname(File.expand_path(__FILE__)), 'code_context')
require File.join(File.dirname(File.expand_path(__FILE__)), 'code_parser')
require File.join(File.dirname(File.expand_path(__FILE__)), 'sniffer')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'source', 'sexp_formatter')

module Reek
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
