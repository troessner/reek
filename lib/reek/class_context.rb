$:.unshift File.dirname(__FILE__)

require 'reek/code_context'

class Class
  def non_inherited_methods
    instance_methods(false) + private_instance_methods(false)
  end

  def is_overriding_method?(sym)
    instance_methods(false).include?(sym) and superclass.instance_methods(true).include?(sym)
  end
end

class MissingClass
  def initialize(ctx)
    @ctx = ctx
  end

  def non_inherited_methods
    @ctx.parsed_methods
  end

  def is_overriding_method?(name)
    false
  end
end

module Reek
  class ClassContext < CodeContext
    attr_accessor :name, :parsed_methods

    def initialize(outer, exp)
      super
      @name = Name.new(exp[1])
      @superclass = exp[2]
      @parsed_methods = []
      @instance_variables = []
    end

    def is_overriding_method?(name)
      my_class.is_overriding_method?(name.to_s)
    end
    
    def is_struct?
      @superclass == [:const, :Struct]
    end

    def num_methods
      my_class.non_inherited_methods.length
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

  private
    
    def my_class
      sym = @name.to_s
      if Object.const_defined?(sym)
        return Object.const_get(sym)
      else
        return MissingClass.new(self)
      end
    end
  end
end
