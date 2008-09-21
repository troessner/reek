$:.unshift File.dirname(__FILE__)

require 'reek/checker'
require 'reek/smells'
require 'reek/object_refs'
require 'set'

module Reek

  class MethodChecker < Checker

    def initialize(smells, klass_name)
      super(smells)
      @class_name = @description = klass_name
      @refs = ObjectRefs.new
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
    
    def record_reference_to_self
      @refs.record_reference_to_self
    end

    def process_attrset(exp)
      record_reference_to_self if /^@/ === exp[1].to_s
      s(exp)
    end

    def process_lit(exp)
      @refs.record_ref(exp)
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
      LongYieldList.check(exp[1], self) unless exp.length < 2
      process(exp[1])
      s(exp)
    end

    def process_call(exp)
      record_receiver(exp[1])
      params = exp[3]
      process(params) if exp.length > 3
      s(exp)
    end

    def process_fcall(exp)
      record_reference_to_self
      process(exp[2]) if exp.length >= 3
      s(exp)
    end

    def process_cfunc(exp)
      record_reference_to_self
      s(exp)
    end

    def process_vcall(exp)
      record_reference_to_self
      s(exp)
    end

    def process_ivar(exp)
      UncommunicativeName.check(exp[1], self, 'field')
      record_reference_to_self
      s(exp)
    end

    def process_lasgn(exp)
      @lvars << exp[1]
      @refs.record_ref(s(:lvar, exp[1]))
      process(exp[2])
      s(exp)
    end

    def process_iasgn(exp)
      record_reference_to_self
      process(exp[2])
      s(exp)
    end

    def process_self(exp)
      record_reference_to_self
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
      @refs.record_ref(receiver) unless MethodChecker.is_global_variable?(receiver)
    end

    def self.unpack_array(receiver)
      receiver = receiver[0] if Array === receiver and Array === receiver[0] and receiver.length == 1
      receiver = :self if receiver == s(:self)
      receiver
    end

    def self.is_override?(class_name, method_name)
      begin
        klass = Object.const_get(class_name)
      rescue
        return false
      end
      klass.superclass.instance_methods.include?(method_name)
    end

    def is_override?
      MethodChecker.is_override?(@class_name, @description.to_s.split('#')[1])
    end

    def check_method_properties
      @lvars.each {|lvar| UncommunicativeName.check(lvar, self, 'local variable') }
      record_reference_to_self if is_override?
      FeatureEnvy.check(@refs, self) unless UtilityFunction.check(@refs, self)
      LongMethod.check(@num_statements, self)
    end
  end
end
