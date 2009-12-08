module Reek

  #
  # A context wrapper representing the root of an abstract syntax tree.
  #
  class StopContext
    
    def initialize
      @refs = ObjectRefs.new
      @name = ''
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

    def full_name
      ''
    end
    
    def inside_a_block?
      false
    end

    def is_overriding_method?(name)
      false
    end
  end
end
