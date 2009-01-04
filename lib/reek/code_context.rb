$:.unshift File.dirname(__FILE__)

module Reek
  class CodeContext
    attr_reader :outer

    def initialize(outer, exp)
      @outer = outer
      @exp = exp
    end
    
    def method_missing(method, *args)
      @outer.send(method, *args)
    end

    def is_overriding_method?(name)
      false
    end

    def num_methods
      0
    end

    def outer_name
      "#{@name}/"
    end

    def to_s
      "#{@outer.outer_name}#{@name}"
    end
  end
end
