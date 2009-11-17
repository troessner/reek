module Reek
  class StopContext
    
    def initialize
      @refs = ObjectRefs.new
      @myself = Object
    end

    def method_missing(method, *args)
      nil
    end

    def count_statements(num)
      0
    end

    def find_module(name)
      sym = name.to_s
      @myself.const_defined?(sym) ? @myself.const_get(sym) : nil
    end
    
    def inside_a_block?
      false
    end

    def is_overriding_method?(name)
      false
    end
    
    def outer_name
      ''
    end
  end
end
