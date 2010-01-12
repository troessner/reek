require File.join( File.dirname( File.expand_path(__FILE__)), 'module_context')

module Reek

  #
  # A context wrapper for any class found in a syntax tree.
  #
  class ClassContext < ModuleContext

    attr_reader :parsed_methods

    def initialize(outer, name, exp)
      super
      @superclass = exp[2]
    end
    
    def is_struct?
      @superclass == [:const, :Struct]
    end
  end
end
