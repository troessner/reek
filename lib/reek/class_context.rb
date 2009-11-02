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

    def initialize(outer, name, exp)
      super
      @superclass = exp[2]
      @instance_variables = Set.new
    end

    def is_overriding_method?(name)
      return false unless myself
      @myself.is_overriding_method?(name.to_s)
    end
    
    def is_struct?
      @superclass == [:const, :Struct]
    end

    def record_instance_variable(sym)
      @instance_variables << Name.new(sym)
    end

    def outer_name
      "#{@outer.outer_name}#{@name}#"
    end

    def variable_names
      @instance_variables
    end
  end
end
