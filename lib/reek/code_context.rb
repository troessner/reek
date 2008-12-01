$:.unshift File.dirname(__FILE__)

module Reek
  class CodeContext
    attr_reader :outer

    def initialize(outer, exp)
      @outer = outer
      @exp = exp
    end

    def count_statements(num)
      @outer.count_statements(num)
    end

    def has_parameter(sym)
      @outer.has_parameter(sym)
    end
    
    def inside_a_block?
      @outer.inside_a_block?
    end

    def local_variables
      @outer.local_variables
    end
    
    def name
      @outer.name
    end

    def num_methods
      0
    end
    
    def num_statements
      @outer.num_statements
    end

    def parameters
      @outer.parameters
    end

    def refs
      @outer.refs
    end
    
    def record_depends_on_self
      @outer.record_depends_on_self
    end
    
    def record_call_to(exp)
      @outer.record_call_to(exp)
    end

    def record_instance_variable(sym)
      @outer.record_instance_variable(sym)
    end

    def record_local_variable(sym)
      @outer.record_local_variable(sym)
    end

    def record_method(name)
      @outer.record_method(name)
    end

    def record_parameter(sym)
      @outer.record_parameter(sym)
    end

    def outer_name
      "#{@name}/"
    end

    def to_s
      "#{@outer.outer_name}#{@name}"
    end
  end
end
