$:.unshift File.dirname(__FILE__)

require 'reek/code_context'

class Class
  def non_inherited_methods
    instance_methods(false) + private_instance_methods(false)
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
    
    def is_struct?
      @superclass == [:const, :Struct]
    end

    def num_methods
      begin
        klass_obj = Object.const_get(@name.to_s)
        return klass_obj.non_inherited_methods.length
      rescue
        return @parsed_methods.length
      end
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
