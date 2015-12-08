require_relative 'context/method_context'
require_relative 'context/module_context'
require_relative 'context/root_context'
require_relative 'context/singleton_method_context'
require_relative 'context/attribute_context'
require_relative 'ast/node'

module Reek
  #
  # Traverses an abstract syntax tree and fires events whenever it encounters
  # specific node types.
  #
  # SMELL: This class is responsible for counting statements and for feeding
  # each context to the smell repository.
  #
  # :reek:TooManyMethods: { max_methods: 29 }
  class ContextBuilder
    attr_reader :context_tree
    private_attr_accessor :element
    private_attr_reader :exp

    def initialize(syntax_tree)
      @exp = syntax_tree
      @element = Context::RootContext.new(exp)
      @context_tree = process(exp)
    end

    private

    # Processes the given AST, memoizes it and returns a tree of nested
    # contexts.
    #
    # For example this ruby code:
    #   class Car; def drive; end; end
    # would get compiled into this AST:
    #   (class
    #     (const nil :Car) nil
    #     (def :drive
    #       (args) nil))
    # Processing this AST would result in a context tree where each node
    # contains the outer context, the AST and the child contexts. The top
    # node is always Reek::Context::RootContext. Using the example above,
    # the tree would look like this:
    #
    # RootContext -> children: 1 ModuleContext -> children: 1 MethodContext
    #
    # @return [Reek::Context::RootContext] tree of nested contexts
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
        increase_statement_count_by(exp.body)
        process_default(exp)
      end
    end

    def process_defs(exp)
      inside_new_context(Context::SingletonMethodContext, exp) do
        increase_statement_count_by(exp.body)
        process_default(exp)
      end
    end

    def process_default(exp)
      exp.children.each do |child|
        process(child) if child.is_a? AST::Node
      end
    end

    def process_args(_) end

    # :reek:TooManyStatements: { max_statements: 6 }
    # :reek:FeatureEnvy
    def process_send(exp)
      if exp.visibility_modifier?
        element.track_visibility(exp.method_name, exp.arg_names)
      end
      if exp.attribute_writer?
        exp.args.each do |arg|
          next unless arg.type == :sym
          new_context(Context::AttributeContext, arg, exp)
        end
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
      increase_statement_count_by(exp.block)
      process_default(exp)
    end

    def process_begin(exp)
      increase_statement_count_by(exp.children)
      decrease_statement_count
      process_default(exp)
    end

    alias_method :process_kwbegin, :process_begin

    def process_if(exp)
      children = exp.children
      increase_statement_count_by(children[1])
      increase_statement_count_by(children[2])
      decrease_statement_count
      process_default(exp)
    end

    def process_while(exp)
      increase_statement_count_by(exp.children[1])
      decrease_statement_count
      process_default(exp)
    end

    alias_method :process_until, :process_while

    def process_for(exp)
      increase_statement_count_by(exp.children[2])
      decrease_statement_count
      process_default(exp)
    end

    def process_rescue(exp)
      increase_statement_count_by(exp.children.first)
      decrease_statement_count
      process_default(exp)
    end

    def process_resbody(exp)
      increase_statement_count_by(exp.children[1..-1].compact)
      process_default(exp)
    end

    def process_case(exp)
      increase_statement_count_by(exp.else_body)
      decrease_statement_count
      process_default(exp)
    end

    def process_when(exp)
      increase_statement_count_by(exp.body)
      process_default(exp)
    end

    def context_processor_exists?(name)
      self.class.private_method_defined?(name)
    end

    # :reek:ControlParameter
    def increase_statement_count_by(sexp)
      element.statement_counter.increase_by sexp
    end

    def decrease_statement_count
      element.statement_counter.decrease_by 1
    end

    def inside_new_context(klass, exp)
      push(new_context(klass, exp)) do
        yield
      end
    end

    def new_context(klass, *args)
      klass.new(element, *args).tap do |scope|
        element.append_child_context(scope)
      end
    end

    def push(scope)
      orig = element
      self.element = scope
      yield
      self.element = orig
    end
  end
end
