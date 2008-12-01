$:.unshift File.dirname(__FILE__)

require 'reek/code_context'

module Reek
  class IfContext < CodeContext
    attr_reader :if_expr
    
    def initialize(outer, exp)
      @outer = outer
      @exp = exp
      @if_expr = exp[1]
    end

    def count_statements(num)
      @outer.count_statements(num)
    end
    
    def has_parameter(exp)
      @outer.has_parameter(exp)
    end
    
    def refs
      @outer.refs
    end
    
    def record_call_to(exp)
      @outer.record_call_to(exp)
    end

    def outer_name
      @outer.outer_name
    end

    def to_s
      @outer.to_s
    end
  end
end
