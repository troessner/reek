$:.unshift File.dirname(__FILE__)

module Reek
  class StopContext
    
    def initialize
      @refs = ObjectRefs.new
    end

    def count_statements(num)
      0
    end

    def has_parameter(sym)
      false
    end
    
    def inside_a_block?
      false
    end

    def is_overriding_method?(name)
      false
    end
    
    def num_statements
      0
    end
    
    def refs
      @refs
    end
    
    def record_depends_on_self
      false
    end
    
    def record_call_to(exp)
      nil
    end

    def record_method(name)
    end

    def record_parameter(sym)
    end

    def record_instance_variable(sym)
    end

    def record_local_variable(sym)
    end
    
    def outer_name
      ''
    end
  end
end
