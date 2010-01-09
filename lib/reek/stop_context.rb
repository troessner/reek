module Reek

  #
  # A context wrapper representing the root of an abstract syntax tree.
  #
  class StopContext
    
    def initialize
      @refs = ObjectRefs.new
      @name = ''
    end

    def method_missing(method, *args)
      nil
    end

    def count_statements(num)
      0
    end

    def full_name
      ''
    end
  end
end
