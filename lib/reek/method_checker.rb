$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'parse_tree'
require 'sexp_processor'
require 'reek/block_context'
require 'reek/class_context'
require 'reek/module_context'
require 'reek/stop_context'
require 'reek/if_context'
require 'reek/method_context'
require 'reek/yield_call_context'
require 'reek/smells/smells'

module Reek

  class MethodChecker < SexpProcessor

    def self.parse_tree_for(code)   # :nodoc:
      ParseTree.new.parse_tree_for_string(code)
    end

    def process_default(exp)
      process_children(exp)
    end

    # Analyses the given Ruby source +code+ looking for smells.
    # Any smells found are saved in the +Report+ object that
    # was passed to this object's constructor.
    def check_source(code)
      check_parse_tree(MethodChecker.parse_tree_for(code))
    end

    # Analyses the given Ruby object +obj+ looking for smells.
    # Any smells found are saved in the +Report+ object that
    # was passed to this object's constructor.
    def check_object(obj)
      check_parse_tree ParseTree.new.parse_tree(obj)
    end

    def check_parse_tree(sexp)  # :nodoc:
      sexp.each { |exp| process(exp) }
    end

    # Creates a new Ruby code checker. Any smells discovered by
    # +check_source+ or +check_object+ will be stored in +report+.
    def initialize(report)
      super()
      @smells = report
      @element = StopContext.new
      @unsupported -= [:cfunc]
      @default_method = :process_default
      @require_empty = @warn_on_default = false
    end

    def process_module(exp)
      @element = ModuleContext.new(@element, exp)
      process_children(exp)
      SMELLS[:module].each {|smell| smell.examine(@element, @smells) }
      pop(exp)
    end

    def process_class(exp)
      @element = ClassContext.new(@element, exp)
      exp[3..-1].each { |sub| process(sub) } unless @element.is_struct?
      SMELLS[:class].each {|smell| smell.examine(@element, @smells) }
      pop(exp)
    end

    def process_defn(exp)
      handle_context(MethodContext, :defn, exp) do |ctx|
        ctx.record_depends_on_self if is_override?
      end
    end

    def process_args(exp)
      exp[1..-1].each {|sym| @element.record_parameter(sym) }
      s(exp)
    end

    def process_attrset(exp)
      @element.record_depends_on_self if /^@/ === exp[1].to_s
      s(exp)
    end

    def process_lit(exp)
      val = exp[1]
      @element.record_depends_on_self if val == :self
      s(exp)
    end

    def process_lvar(exp)
      s(exp)
    end

    def process_iter(exp)
      process(exp[1])
      handle_context(BlockContext, :iter, exp[1..-1])
    end
    
    def process_dasgn_curr(exp)
      @element.record_parameter(exp[1])
      process_children(exp)
      s(exp)
    end

    def process_block(exp)
      @element.count_statements(MethodChecker.count_statements(exp))
      process_children(exp)
    end

    def process_yield(exp)
      handle_context(YieldCallContext, :yield, exp)
    end

    def process_call(exp)
      @element.record_call_to(exp)
      receiver, meth = exp[1..2]
      @element.refs.record_ref(receiver) if (receiver[0] == :lvar and meth != :new)
      process_children(exp)
    end

    def process_fcall(exp)
      @element.record_depends_on_self
      @element.refs.record_reference_to_self
      process_children(exp)
    end

    def process_cfunc(exp)
      @element.record_depends_on_self
      s(exp)
    end

    def process_vcall(exp)
      @element.record_depends_on_self
      s(exp)
    end

    def process_if(exp)
      handle_context(IfContext, :if, exp)
    end

    def process_ivar(exp)
      @element.instance_variables << exp[1]
      @element.record_depends_on_self
      s(exp)
    end

    def process_gvar(exp)
      s(exp)
    end

    def process_lasgn(exp)
      @element.record_local_variable(exp[1])
      process(exp[2])
      s(exp)
    end

    def process_iasgn(exp)
      @element.record_instance_variable(exp[1])
      @element.record_depends_on_self
      process_children(exp)
    end

    def process_self(exp)
      @element.record_depends_on_self
      s(exp)
    end

  private

    def self.count_statements(exp)
      result = exp.length - 1
      result -= 1 if Array === exp[1] and exp[1][0] == :args
      result -= 1 if exp[2] == s(:nil)
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
      return false unless klass.superclass
      klass.superclass.instance_methods.include?(method_name)
    end

    def is_override?
      MethodChecker.is_override?(@class_name, @name)
    end

    def handle_context(klass, type, exp)
      @element = klass.new(@element, exp)
      process_children(exp)
      yield(@element) if block_given?
      SMELLS[type].each {|smell| smell.examine(@element, @smells) }
      pop(exp)
    end
    
    def pop(exp)
      @element = @element.outer
      s(exp)
    end

    def process_children(exp)
      exp[1..-1].each { |sub| process(sub) if Array === sub }
      s(exp)
    end

    def check_smells_for(type)
      SMELLS[type].each {|smell| smell.examine(@element, @smells) }
    end
  end
end
