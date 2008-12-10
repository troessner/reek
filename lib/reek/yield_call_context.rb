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
  end
end
