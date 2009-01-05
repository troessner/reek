$:.unshift File.dirname(__FILE__)

module Reek
  class CodeContext
    attr_reader :outer

    def initialize(outer, exp)
      @outer = outer
      @exp = exp
      @myself = nil
    end

    def myself
      @myself ||= @outer.find_module(@name)
    end

    def find_module(name)
      sym = name.to_s
      myself.const_defined?(sym) ? myself.const_get(sym) : nil
    end
    
    def method_missing(method, *args)
      @outer.send(method, *args)
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
