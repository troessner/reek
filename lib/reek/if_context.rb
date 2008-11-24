$:.unshift File.dirname(__FILE__)

module Reek
  class IfContext
    attr_reader :if_expr
    
    def initialize(outer, exp)
      @outer = outer
      @exp = exp
      @if_expr = exp[1]
    end
    
    def has_parameter(exp)
      # TODO: should be @outer.has_parameter(exp)
      @outer.parameters.include?(exp[1])
    end

    def to_s
      @outer.to_s
    end
  end
end
