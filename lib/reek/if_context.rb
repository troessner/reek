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

    def outer_name
      @outer.outer_name
    end

    def to_s
      @outer.to_s
    end
  end
end
