require_relative 'context/method_context'
require_relative 'context/module_context'
require_relative 'context/root_context'
require_relative 'context/singleton_method_context'
require_relative 'ast/node'

module Reek
  #
  # Traverses an abstract syntax tree and fires events whenever it encounters
  # specific node types.
  #
  # SMELL: This class is responsible for counting statements and for feeding
  # each context to the smell repository.
  #
  # TODO: Make TreeWalker responsible only for creating Context objects, and
  # loop over the created set of contexts elsewhere.
  #
  # @api private
  class TreeWalker
    def initialize(smell_repository, exp)
      @smell_repository = smell_repository
      @exp = exp
      @element = Context::RootContext.new(exp)
    end

    def walk
      result.each do |element|
        smell_repository.examine(element)
      end
    end

    private

    private_attr_accessor :element
    private_attr_reader :exp, :smell_repository

    def result
      @result ||= process(exp)
    end

    def process(exp)
      context_processor = "process_#{exp.type}"
      if context_processor_exists?(context_processor)
        send(context_processor, exp)
      else
        process_default exp
      end
      element
    end

    def process_module(exp)
      inside_new_context(Context::ModuleContext, exp) do
        process_default(exp)
      end
    end

    alias_method :process_class, :process_module

    def process_casgn(exp)
      if exp.defines_module?
        process_module(exp)
      else
        process_default(exp)
      end
    end

    def process_def(exp)
      inside_new_context(Context::MethodContext, exp) do
        count_clause(exp.body)
        process_default(exp)
      end
    end

    def process_defs(exp)
      inside_new_context(Context::SingletonMethodContext, exp) do
        count_clause(exp.body)
        process_default(exp)
      end
    end

    def process_default(exp)
      exp.children.each do |child|
        process(child) if child.is_a? AST::Node
      end
    end

    def process_args(_) end

    #
    # Recording of calls to methods and self
    #

    def process_send(exp)
      if visibility_modifier? exp
        element.track_visibility(exp.method_name, exp.arg_names)
      end
      element.record_call_to(exp)
      process_default(exp)
    end

    def process_attrasgn(exp)
      element.record_call_to(exp)
      process_default(exp)
    end

    alias_method :process_op_asgn, :process_attrasgn

    def process_ivar(exp)
      element.record_use_of_self
      process_default(exp)
    end

    alias_method :process_ivasgn, :process_ivar

    def process_self(_)
      element.record_use_of_self
    end

    alias_method :process_zsuper, :process_self

    #
    # Statement counting
    #

    def process_block(exp)
      count_clause(exp.block)
      process_default(exp)
    end

    def process_begin(exp)
      count_statement_list(exp.children)
      element.count_statements(-1)
      process_default(exp)
    end

    alias_method :process_kwbegin, :process_begin

    def process_if(exp)
      count_clause(exp[2])
      count_clause(exp[3])
      element.count_statements(-1)
      process_default(exp)
    end

    def process_while(exp)
      count_clause(exp[2])
      element.count_statements(-1)
      process_default(exp)
    end

    alias_method :process_until, :process_while

    def process_for(exp)
      count_clause(exp[3])
      element.count_statements(-1)
      process_default(exp)
    end

    def process_rescue(exp)
      count_clause(exp[1])
      element.count_statements(-1)
      process_default(exp)
    end

    def process_resbody(exp)
      count_statement_list(exp[2..-1].compact)
      process_default(exp)
    end

    def process_case(exp)
      count_clause(exp.else_body)
      element.count_statements(-1)
      process_default(exp)
    end

    def process_when(exp)
      count_clause(exp.body)
      process_default(exp)
    end

    def context_processor_exists?(name)
      self.class.private_method_defined?(name)
    end

    def count_clause(sexp)
      element.count_statements(1) if sexp
    end

    def count_statement_list(statement_list)
      element.count_statements statement_list.length
    end

    def inside_new_context(klass, exp)
      scope = klass.new(element, exp)
      element.append_child_context(scope)
      push(scope) do
        yield
      end
      scope
    end

    def push(scope)
      orig = element
      self.element = scope
      yield
      self.element = orig
    end

    # FIXME: Move to SendNode?
    def visibility_modifier?(call_node)
      VISIBILITY_MODIFIERS.include?(call_node.method_name)
    end

    VISIBILITY_MODIFIERS = [:private, :public, :protected, :module_function]
  end
end
