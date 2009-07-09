require 'rubygems'
require 'sexp'
require 'reek/block_context'
require 'reek/class_context'
require 'reek/module_context'
require 'reek/stop_context'
require 'reek/if_context'
require 'reek/method_context'
require 'reek/singleton_method_context'
require 'reek/yield_call_context'

#
# Extensions to +Sexp+ to allow +CodeParser+ to navigate the abstract
# syntax tree more easily.
#
class Sexp
  def children
    find_all { |item| Sexp === item }
  end

  def is_language_node?
    first.class == Symbol
  end

  def has_type?(type)
    is_language_node? and first == type
  end
end

module Reek

  class CodeParser

    #
    # Creates a new Ruby code checker.
    #
    def initialize(sniffer, ctx = StopContext.new)
      @sniffer = sniffer
      @element = ctx
    end

    def process(exp)
      meth = "process_#{exp[0]}"
      meth = :process_default unless self.respond_to?(meth)
      self.send(meth, exp)
      @element
    end

    def process_default(exp)
      exp[0..-1].each { |sub| process(sub) if Array === sub }
    end

    def process_module(exp)
      push(ModuleContext.create(@element, exp)) do
        process_default(exp)
        check_smells(:module)
      end
    end

    def process_class(exp)
      scope = ClassContext.create(@element, exp)
      push(scope) do
        process_default(exp) unless @element.is_struct?
        check_smells(:class)
      end
      scope
    end

    def process_defn(exp)
      handle_context(MethodContext, :defn, exp)
    end

    def process_defs(exp)
      handle_context(SingletonMethodContext, :defs, exp)
    end

    def process_args(exp)
      exp[1..-1].each {|sym| @element.record_parameter(sym) }
    end

    def process_attrset(exp)
      @element.record_depends_on_self if /^@/ === exp[1].to_s
    end

    def process_lit(exp)
      val = exp[1]
      @element.record_depends_on_self if val == :self
    end

    def process_iter(exp)
      process(exp[1])
      handle_context(BlockContext, :iter, exp[2..-1])
    end
    
    def process_dasgn_curr(exp)
      @element.record_parameter(exp[1])
      process_default(exp)
    end

    def process_block(exp)
      @element.count_statements(CodeParser.count_statements(exp))
      process_default(exp)
    end

    def process_yield(exp)
      handle_context(YieldCallContext, :yield, exp)
    end

    def process_call(exp)
      @element.record_call_to(exp)
      process_default(exp)
    end

    def process_cfunc(exp)
      @element.record_depends_on_self
    end

    def process_attrasgn(exp)
      process_call(exp)
    end

    def process_op_asgn1(exp)
      process_call(exp)
    end

    def process_if(exp)
      count_clause(exp[2])
      count_clause(exp[3])
      handle_context(IfContext, :if, exp)
      @element.count_statements(-1)
    end

    def process_while(exp)
      process_until(exp)
    end

    def process_until(exp)
      count_clause(exp[2])
      process_default(exp)
      @element.count_statements(-1)
    end

    def process_for(exp)
      count_clause(exp[3])
      process_case(exp)
    end

    def process_rescue(exp)
      count_clause(exp[1])
      process_case(exp)
    end

    def process_resbody(exp)
      process_when(exp)
    end

    def process_case(exp)
      process_default(exp)
      @element.count_statements(-1)
    end

    def process_when(exp)
      count_clause(exp[2])
      process_default(exp)
    end

    def process_ivar(exp)
      process_iasgn(exp)
    end

    def process_lasgn(exp)
      @element.record_local_variable(exp[1])
      process_default(exp)
    end

    def process_iasgn(exp)
      @element.record_instance_variable(exp[1])
      @element.record_depends_on_self
      process_default(exp)
    end

    def process_self(exp)
      @element.record_depends_on_self
    end

    def count_clause(sexp)
      if sexp and !sexp.has_type?(:block)
        @element.count_statements(1)
      end
    end

    def self.count_statements(exp)
      stmts = exp[1..-1]
      ignore = 0
      ignore += 1 if stmts[1] == s(:nil)
      stmts.length - ignore
    end

  private

    def handle_context(klass, type, exp)
      scope = klass.new(@element, exp)
      push(scope) do
        process_default(exp)
        check_smells(type)
      end
      scope
    end

    def check_smells(type)
      @sniffer.examine(@element, type)
    end

    def push(context)
      orig = @element
      @element = context
      yield
      @element = orig
    end
  end
end
