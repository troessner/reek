require 'reek/code_context'

class Class
  def non_inherited_methods
    instance_methods(false) + private_instance_methods(false)
  end

  def is_overriding_method?(sym)
    instance_methods(false).include?(sym) and superclass.instance_methods(true).include?(sym)
  end
end

module Reek
  class ClassContext < CodeContext
    attr_accessor :name

    def initialize(outer, exp)
      super
      @name = Name.new(exp[1])
      @superclass = exp[2]
      @parsed_methods = []
      @instance_variables = []
    end

    def is_overriding_method?(name)
      return false unless myself
      myself.is_overriding_method?(name.to_s)
    end
    
    def is_struct?
      @superclass == [:const, :Struct]
    end

    def num_methods
      meths = myself ? myself.non_inherited_methods : @parsed_methods
      meths.length
    end

    def record_instance_variable(sym)
      @instance_variables << Name.new(sym)
    end

    def record_method(name)
      @parsed_methods << name.to_s
    end

    def outer_name
      "#{@outer.outer_name}#{@name}#"
    end

    def to_s
      "#{@outer.outer_name}#{@name}"
    end

    def variable_names
      @instance_variables
    end
  end
end
