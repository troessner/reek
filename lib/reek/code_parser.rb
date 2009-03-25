require 'rubygems'
require 'parse_tree'
require 'sexp_processor'
require 'reek/block_context'
require 'reek/class_context'
require 'reek/module_context'
require 'reek/stop_context'
require 'reek/if_context'
require 'reek/method_context'
require 'reek/singleton_method_context'
require 'reek/yield_call_context'

module Reek

  class CodeParser < SexpProcessor

    def self.parse_tree_for(code)   # :nodoc:
      ParseTree.new.parse_tree_for_string(code)
    end

    # Creates a new Ruby code checker. Any smells discovered by
    # +check_source+ or +check_object+ will be stored in +report+.
    def initialize(report, smells, ctx = StopContext.new)
      super()
      @report = report
      @smells = smells
      @element = ctx
      @unsupported -= [:cfunc]
      @default_method = :process_default
      @require_empty = @warn_on_default = false
    end

    # Analyses the given Ruby source +code+ looking for smells.
    # Any smells found are saved in the +Report+ object that
    # was passed to this object's constructor.
    def check_source(code)
      check_parse_tree(CodeParser.parse_tree_for(code))
    end

    # Analyses the given Ruby object +obj+ looking for smells.
    # Any smells found are saved in the +Report+ object that
    # was passed to this object's constructor.
    def check_object(obj)
      check_parse_tree(ParseTree.new.parse_tree(obj))
    end

    def process_default(exp)
      exp[1..-1].each { |sub| process(sub) if Array === sub }
      s(exp)
    end

    def process_module(exp)
      push(ModuleContext.create(@element, exp)) do
        process_default(exp)
        check_smells(:module)
      end
      s(exp)
    end

    def process_class(exp)
      push(ClassContext.create(@element, exp)) do
        process_default(exp) unless @element.is_struct?
        check_smells(:class)
      end
      s(exp)
    end

    def process_defn(exp)
      handle_context(MethodContext, :defn, exp)
    end

    def process_defs(exp)
      handle_context(SingletonMethodContext, :defs, exp)
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

    def process_iter(exp)
      process(exp[1])
      handle_context(BlockContext, :iter, exp[1..-1])
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

    def process_fcall(exp)
      @element.record_depends_on_self
      @element.refs.record_reference_to_self
      process_default(exp)
    end

    def process_cfunc(exp)
      @element.record_depends_on_self
      s(exp)
    end

    def process_vcall(exp)
      @element.record_depends_on_self
      @element.refs.record_reference_to_self
      s(exp)
    end

    def process_if(exp)
      handle_context(IfContext, :if, exp)
    end

    def process_ivar(exp)
      process_iasgn(exp)
    end

    def process_lasgn(exp)
      @element.record_local_variable(exp[1])
      process(exp[2])
      s(exp)
    end

    def process_iasgn(exp)
      @element.record_instance_variable(exp[1])
      @element.record_depends_on_self
      process_default(exp)
    end

    def process_self(exp)
      @element.record_depends_on_self
      s(exp)
    end

  private

    def self.count_statements(exp)
      stmts = exp[1..-1]
      ignore = 0
      ignore = 1 if is_expr?(stmts[0], :args)
      ignore += 1 if stmts[1] == s(:nil)
      stmts.length - ignore
    end

    def self.is_expr?(exp, type)
      Array === exp and exp[0] == type
    end

    def self.is_global_variable?(exp)
      is_expr?(exp, :gvar)
    end

    def handle_context(klass, type, exp)
      push(klass.new(@element, exp)) do
        process_default(exp)
        check_smells(type)
      end
      s(exp)
    end

    def check_smells(type)
      @smells[type].each {|smell| smell.examine(@element, @report) }
    end

    def push(context)
      orig = @element
      @element = context
      yield
      @element = orig
    end
    
    def pop(exp)
      @element = @element.outer
      s(exp)
    end

    def check_parse_tree(sexp)  # :nodoc:
      sexp.each { |exp| process(exp) }
    end
  end
end
