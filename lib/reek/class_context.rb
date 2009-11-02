require 'set'
require 'reek/module_context'

class Class
  def is_overriding_method?(name)
    sym = name.to_sym
    mine = instance_methods(false)
    dads = superclass.instance_methods(true)
    (mine.include?(sym) and dads.include?(sym)) or (mine.include?(name) and dads.include?(name))
  end
end

module Reek
  class ClassContext < ModuleContext

    attr_reader :parsed_methods

    # SMELL: inconsistent with other contexts (not linked to the sexp)
    def initialize(outer, name, exp = nil)
      super(outer, name, exp)
      @superclass = exp[2] if exp
      @parsed_methods = []
      @instance_variables = Set.new
    end

    def is_overriding_method?(name)
      return false unless myself
      @myself.is_overriding_method?(name.to_s)
    end
    
    def is_struct?
      @superclass == [:const, :Struct]
    end

    def num_methods
      @parsed_methods.length
    end

    def record_instance_variable(sym)
      @instance_variables << Name.new(sym)
    end

    def record_method(meth)
      @parsed_methods << meth
    end

    def outer_name
      "#{@outer.outer_name}#{@name}#"
    end

    def variable_names
      @instance_variables
    end

    def parameterized_methods(min_clump_size)
      parsed_methods.select {|meth| meth.parameters.length >= min_clump_size }
    end
  end
end
