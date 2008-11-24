$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'method_checker'
require 'reek/smells/smells'

module Reek
  class YieldCallContext
    attr_reader :args
    
    def initialize(outer, exp)
      @outer = outer
      @exp = exp
      @args = @exp[1]
    end

    def to_s
      @outer.to_s
    end
  end
end
