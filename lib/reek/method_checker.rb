$:.unshift File.dirname(__FILE__)

require 'reek/checker'
require 'reek/smells'
require 'set'

module Reek

  class MethodChecker < Checker

    def initialize(smells, klass_name)
      super(smells)
      @class_name = klass_name
      @description = klass_name
      @calls = Hash.new(0)
      @lvars = Set.new
      @inside_an_iter = false
    end

    def process_defn(exp)
      @num_statements = 0
      @description = "#{@class_name}##{exp[1]}"
      UncommunicativeName.check(exp[1], self, 'method')
      process(exp[2])
      @lvars.each {|lvar| UncommunicativeName.check(lvar, self, 'local variable') }
      UtilityFunction.check(@calls, self)
      FeatureEnvy.check(@calls, self)
      LongMethod.check(@num_statements, self)
      s(exp)
    end

    def process_args(exp)
      LongParameterList.check(exp, self)
      exp.each { |arg| UncommunicativeName.check(arg, self, 'parameter') }
      s(exp)
    end

    def process_attrset(exp)
      @calls[:self] += 1 if /^@/ === exp[1].to_s
      s(exp)
    end

    def process_iter(exp)
      NestedIterators.check(@inside_an_iter, self)
      @inside_an_iter = true
      exp[1..-1].each { |s| process(s) }
      @inside_an_iter = false
      s(exp)
    end

    def process_block(exp)
      @num_statements += count_statements(exp)
      exp[1..-1].each { |s| process(s) }
      s(exp)
    end

    def process_yield(exp)
      LongYieldList.check(exp[1], self)
      process(exp[1])
      s(exp)
    end

    def process_call(exp)
      receiver = process(exp[1])
      receiver = receiver[0] if Array === receiver and Array === receiver[0] and receiver.length == 1
      if receiver[0] != :gvar
        receiver = :self if receiver == s(:self)
        @calls[receiver] += 1
      end
      process(exp[3]) if exp.length > 3
      s(exp)
    end

    def process_fcall(exp)
      @calls[:self] += 1
      process(exp[2]) if exp.length > 2
      s(exp)
    end

    def process_cfunc(exp)
      @calls[:self] += 1
      s(exp)
    end

    def process_vcall(exp)
      @calls[:self] += 1
      s(exp)
    end

    def process_ivar(exp)
      UncommunicativeName.check(exp[1], self, 'field')
      @calls[:self] += 1
      s(exp)
    end

    def process_lasgn(exp)
      @lvars << exp[1]
      @calls[s(:lvar, exp[1])] += 1
      process(exp[2])
      s(exp)
    end

    def process_iasgn(exp)
      @calls[:self] += 1
      process(exp[2])
      s(exp)
    end

  private
    
    def count_statements(exp)
      result = exp.length - 1
      result -= 1 if Array === exp[1] and exp[1][0] == :args
      result
    end
  end
end
