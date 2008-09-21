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

    def process_attrset(exp)
      @refs.record_reference_to_self if /^@/ === exp[1].to_s
      s(exp)
    end

    def process_lit(exp)
      @refs.record_ref(exp)
      s(exp)
    end

    def process_lvar(exp)
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
      args = exp[1]
      if args
        LongYieldList.check(args, self)
        process(args)
      end
      s(exp)
    end

    def process_call(exp)
      receiver, meth, args = exp[1..3]
      process(receiver)
      process(args) if args
      s(exp)
    end

    def process_fcall(exp)
      @refs.record_reference_to_self
      process(exp[2]) if exp.length >= 3
      s(exp)
    end

    def process_cfunc(exp)
      @refs.record_reference_to_self
      s(exp)
    end

    def process_vcall(exp)
      @refs.record_reference_to_self
      s(exp)
    end

    def process_ivar(exp)
      UncommunicativeName.check(exp[1], self, 'field')
      @refs.record_reference_to_self  # BUG: also a ref to the ivar!
      s(exp)
    end

    def process_gvar(exp)
      s(exp)
    end

    def process_lasgn(exp)
      @lvars << exp[1]
      process(exp[2])
      s(exp)
    end

    def process_iasgn(exp)
      @refs.record_reference_to_self
      process(exp[2])
      s(exp)
    end

    def process_self(exp)
      @refs.record_reference_to_self
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
      @refs.record_reference_to_self if is_override?
      FeatureEnvy.check(@refs, self) unless UtilityFunction.check(@refs, self)
      LongMethod.check(@num_statements, self)
    end
  end
end
