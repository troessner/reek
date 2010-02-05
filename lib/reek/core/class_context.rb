require File.join(File.dirname(File.expand_path(__FILE__)), 'module_context')

module Reek
  module Core

    #
    # A context wrapper for any class found in a syntax tree.
    #
    class ClassContext < ModuleContext

      attr_reader :parsed_methods

      def initialize(outer, name, exp)
        super
      end

      def is_struct?
        exp.superclass == [:const, :Struct]
      end
    end
  end
end
