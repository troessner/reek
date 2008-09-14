$:.unshift File.dirname(__FILE__)

require 'reek/checker'
require 'reek/smells'
require 'set'

module Reek

  class MethodChecker < Checker

    def initialize(smells, klass_name)
      super(smells)
      @class_name = @description = klass_name
      @calls = Hash.new(0)
      @lvars = Set.new
      @num_statements = 0
    end

    def process_defn(exp)
      @description = "#{@class_name}##{exp[1]}"
      UncommunicativeName.check(exp[1], self, 'method')
      process(exp[2])
      check_method_properties
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
      @num_statements += MethodChecker.count_statements(exp)
      exp[1..-1].each { |s| process(s) }
      s(exp)
    end

    def process_yield(exp)
      LongYieldList.check(exp[1], self)
      process(exp[1])
      s(exp)
    end

    def process_call(exp)
      record_receiver(exp[1])
      process_actual_parameters(exp[3])
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

    def self.count_statements(exp)
      result = exp.length - 1
      result -= 1 if Array === exp[1] and exp[1][0] == :args
      result
    end

    def self.is_global_variable?(exp)
      Array === exp and exp[0] == :gvar
    end

    def record_receiver(exp)
      receiver = MethodChecker.unpack_array(process(exp))
      @calls[receiver] += 1 unless MethodChecker.is_global_variable?(receiver)
    end

    def self.unpack_array(receiver)
      receiver = receiver[0] if Array === receiver and Array === receiver[0] and receiver.length == 1
      receiver = :self if receiver == s(:self)
      receiver
    end

    def is_override?
      begin
        klass = Object.const_get(@class_name)
      rescue
        return false
      end
      klass.superclass.instance_methods.include?(@description.to_s.split('#')[1])
    end

    def check_method_properties
      @lvars.each {|lvar| UncommunicativeName.check(lvar, self, 'local variable') }
      @calls[:self] += 1 if is_override?
      UtilityFunction.check(@calls, self)
      FeatureEnvy.check(@calls, self)
      LongMethod.check(@num_statements, self)
    end

    def process_actual_parameters(exp)
      return unless Array === exp and exp[0] == :array
      exp[1..-1].each do |param|
        if Array === param
          if param.length == 1
            @calls[:self] += 1 if param[0] == :self
          else
            @calls[param] += 1
          end
        else
          @calls[:self] += 1 if param == :self
        end
      end
    end
  end
end
