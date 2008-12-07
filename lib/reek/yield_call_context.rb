$:.unshift File.dirname(__FILE__)

require 'reek/smells/smells'
require 'reek/code_context'

module Reek
  class YieldCallContext < CodeContext
    attr_reader :args, :outer
    
    def initialize(outer, exp)
      @outer = outer
      @exp = exp
      @args = @exp[1]
    end

    def count_statements(num)
      @outer.count_statements(num)
    end
    
    def record_call_to(exp)
      @outer.record_call_to(exp)
    end
    
    def record_depends_on_self
      @outer.record_depends_on_self
    end

    def to_s
      @outer.to_s
    end
  end
end
