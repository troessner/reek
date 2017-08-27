# frozen_string_literal: true

require_relative 'context/attribute_context'
require_relative 'context/class_context'
require_relative 'context/ghost_context'
require_relative 'context/method_context'
require_relative 'context/module_context'
require_relative 'context/root_context'
require_relative 'context/send_context'
require_relative 'context/singleton_attribute_context'
require_relative 'context/singleton_method_context'
require_relative 'ast/node'

module Reek
  #
  # Traverses an abstract syntax tree and fires events whenever it encounters
  # specific node types.
  #
  # TODO: This class is responsible for statements and reference
  # counting. Ideally `ContextBuilder` would only build up the context tree and leave the
  # statement and reference counting to the contexts.
  #
  # :reek:TooManyMethods: { max_methods: 31 }
  # :reek:UnusedPrivateMethod: { exclude: [ !ruby/regexp /process_/ ] }
  # :reek:DataClump
  class ContextBuilder
    attr_reader :context_tree

    def initialize(syntax_tree)
      @exp = syntax_tree
      @current_context = Context::RootContext.new(exp)
      @context_tree = build(exp)
    end

    private

    attr_accessor :current_context
    attr_reader :exp

    # Processes the given AST, memoizes it and returns a tree of nested
    # contexts.
    #
    # For example this ruby code:
    #
    #   class Car; def drive; end; end
    #
    # would get compiled into this AST:
    #
    #   (class
    #     (const nil :Car) nil
    #     (def :drive
    #       (args) nil))
    #
    # Processing this AST would result in a context tree where each node
    # contains the outer context, the AST and the child contexts. The top
    # node is always Reek::Context::RootContext. Using the example above,
    # the tree would look like this:
    #
    # RootContext -> children: 1 ModuleContext -> children: 1 MethodContext
    #
    # @return [Reek::Context::RootContext] tree of nested contexts
    def build(exp, parent_exp = nil)
      context_processor = "process_#{exp.type}"
      if context_processor_exists?(context_processor)
        send(context_processor, exp, parent_exp)
      else
        process exp
      end
      current_context
    end

    # Handles every node for which we have no context_processor.
    #
    def process(exp)
      exp.children.grep(AST::Node).each { |child| build(child, exp) }
    end

    # Handles `module` and `class` nodes.
    #
    def process_module(exp, _parent)
      inside_new_context(Context::ModuleContext, exp) do
        process(exp)
      end
    end

    alias process_class process_module

    # Handles `sclass` nodes
    #
    # An input example that would trigger this method would be:
    #
    #   class << self
    #   end
    #
    def process_sclass(exp, _parent)
      inside_new_context(Context::GhostContext, exp) do
        process(exp)
      end
    end

    # Handles `casgn` ("class assign") nodes.
    #
    # An input example that would trigger this method would be:
    #
    #   Foo = Class.new Bar
    #
    def process_casgn(exp, parent)
      if exp.defines_module?
        process_module(exp, parent)
      else
        process(exp)
      end
    end

    # Handles `def` nodes.
    #
    # An input example that would trigger this method would be:
    #
    #   def call_me; foo = 2; bar = 5; end
    #
    # Given the above example we would count 2 statements overall.
    #
    def process_def(exp, parent)
      inside_new_context(current_context.method_context_class, exp, parent) do
        increase_statement_count_by(exp.body)
        process(exp)
      end
    end

    # Handles `defs` nodes ("define singleton").
    #
    # An input example that would trigger this method would be:
    #
    #   def self.call_me; foo = 2; bar = 5; end
    #
    # Given the above example we would count 2 statements overall.
    #
    def process_defs(exp, parent)
      inside_new_context(Context::SingletonMethodContext, exp, parent) do
        increase_statement_count_by(exp.body)
        process(exp)
      end
    end

    # Handles `send` nodes a.k.a. method calls.
    #
    # An input example that would trigger this method would be:
    #
    #   call_me()
    #
    # Besides checking if it's a visibility modifier or an attribute writer
    # we also record to what the method call is referring to
    # which we later use for smell detectors like FeatureEnvy.
    #
    def process_send(exp, _parent)
      process(exp)
      case current_context
      when Context::ModuleContext
        handle_send_for_modules exp
      when Context::MethodContext
        handle_send_for_methods exp
      end
    end

    # Handles `op_asgn` nodes a.k.a. Ruby's assignment operators.
    #
    # An input example that would trigger this method would be:
    #
    #   x += 5
    #
    # or
    #
    #   x *= 3
    #
    # We record one reference to `x` given the example above.
    #
    def process_op_asgn(exp, _parent)
      current_context.record_call_to(exp)
      process(exp)
    end

    # Handles `ivasgn` and `ivar` nodes a.k.a. nodes related to instance variables.
    #
    # An input example that would trigger this method would be:
    #
    #   @item = 5
    #
    # for instance assignments (`ivasgn`) and
    #
    #   call_me(@item)
    #
    # for just using instance variables (`ivar`).
    #
    # We record one reference to `self`.
    #
    def process_ivar(exp, _parent)
      current_context.record_use_of_self
      process(exp)
    end

    alias process_ivasgn process_ivar

    # Handles `self` nodes.
    #
    # An input example that would trigger this method would be:
    #
    #   def self.foo; end
    #
    def process_self(_, _parent)
      current_context.record_use_of_self
    end

    # Handles `zsuper` nodes a.k.a. calls to `super` without any arguments but a block possibly.
    #
    # An input example that would trigger this method would be:
    #
    #   def call_me; super; end
    #
    # or
    #
    #   def call_me; super do end; end
    #
    # but not
    #
    #   def call_me; super(); end
    #
    # We record one reference to `self`.
    #
    def process_zsuper(_, _parent)
      current_context.record_use_of_self
    end

    # Handles `super` nodes a.k.a. calls to `super` with arguments
    #
    # An input example that would trigger this method would be:
    #
    #   def call_me; super(); end
    #
    # or
    #
    #   def call_me; super(bar); end
    #
    # but not
    #
    #   def call_me; super; end
    #
    # and not
    #
    #   def call_me; super do end; end
    #
    # We record one reference to `self`.
    #
    def process_super(exp, _parent)
      current_context.record_use_of_self
      process(exp)
    end

    # Handles `block` nodes.
    #
    # An input example that would trigger this method would be:
    #
    #   list.map { |element| puts element }
    #
    # Counts non-empty blocks as one statement.
    #
    def process_block(exp, _parent)
      increase_statement_count_by(exp.block)
      process(exp)
    end

    # Handles `begin` and `kwbegin` nodes. `begin` nodes are created implicitly
    # e.g. when parsing method bodies (see example below), `kwbegin` nodes are created
    # by explicitly using the `begin` keyword.
    #
    # An input example that would trigger this method would be:
    #
    #   def foo; call_me(); @x = 5; end
    #
    # In this case the whole method body would be hanging below the `begin` node.
    #
    # Counts all statements in the method body.
    #
    # At the end we subtract one statement because the surrounding context was already counted
    # as one (e.g. via `process_def`).
    #
    def process_begin(exp, _parent)
      increase_statement_count_by(exp.children)
      decrease_statement_count
      process(exp)
    end

    alias process_kwbegin process_begin

    # Handles `if` nodes.
    #
    # An input example that would trigger this method would be:
    #
    # if a > 5 && b < 3
    #   puts 'bingo'
    # else
    #   3
    # end
    #
    # Counts the `if` body as one statement and the `else` body as another statement.
    #
    # At the end we subtract one statement because the surrounding context was already counted
    # as one (e.g. via `process_def`).
    #
    # `children[1]` refers to the `if` body (so `puts 'bingo'` from above) and
    # `children[2]` to the `else` body (so `3` from above), which might be nil.
    #
    def process_if(exp, _parent)
      children = exp.children
      increase_statement_count_by(children[1])
      increase_statement_count_by(children[2])
      decrease_statement_count
      process(exp)
    end

    # Handles `while` and `until` nodes.
    #
    # An input example that would trigger this method would be:
    #
    # while x < 5
    #   puts 'bingo'
    # end
    #
    # Counts the `while` body as one statement.
    #
    # At the end we subtract one statement because the surrounding context was already counted
    # as one (e.g. via `process_def`).
    #
    # `children[1]` below refers to the `while` body (so `puts 'bingo'` from above)
    #
    def process_while(exp, _parent)
      increase_statement_count_by(exp.children[1])
      decrease_statement_count
      process(exp)
    end

    alias process_until process_while

    # Handles `for` nodes.
    #
    # An input example that would trigger this method would be:
    #
    # for i in [1,2,3,4]
    #   puts i
    # end
    #
    # Counts the `for` body as one statement.
    #
    # At the end we subtract one statement because the surrounding context was already counted
    # as one (e.g. via `process_def`).
    #
    # `children[2]` below refers to the `while` body (so `puts i` from above)
    #
    def process_for(exp, _parent)
      increase_statement_count_by(exp.children[2])
      decrease_statement_count
      process(exp)
    end

    # Handles `rescue` nodes.
    #
    # An input example that would trigger this method would be:
    #
    # def simple
    #   raise ArgumentError, 'raising...'
    # rescue => e
    #   puts 'rescued!'
    # end
    #
    # Counts everything before the `rescue` body as one statement.
    #
    # At the end we subtract one statement because the surrounding context was already counted
    # as one (e.g. via `process_def`).
    #
    # `exp.children.first` below refers to everything before the actual `rescue`
    # which would be the
    #
    # raise ArgumentError, 'raising...'
    #
    # in the example above.
    # `exp` would be the whole method body wrapped under a `rescue` node.
    # See `process_resbody` for additional reference.
    #
    def process_rescue(exp, _parent)
      increase_statement_count_by(exp.children.first)
      decrease_statement_count
      process(exp)
    end

    # Handles `resbody` nodes.
    #
    # An input example that would trigger this method would be:
    #
    # def simple
    #   raise ArgumentError, 'raising...'
    # rescue => e
    #   puts 'rescued!'
    # end
    #
    # Counts the exception capturing and every statement related to it.
    #
    # So `exp.children[1..-1]` from the code below would be an array with the following 2 elements:
    # [
    #   (lvasgn :e),
    #   (send nil :puts (str "rescued!"))
    # ]
    #
    # which thus counts as 2 statements.
    # `exp` would be the whole `rescue` body.
    # See `process_rescue` for additional reference.
    #
    def process_resbody(exp, _parent)
      increase_statement_count_by(exp.children[1..-1].compact)
      process(exp)
    end

    # Handles `case` nodes.
    #
    # An input example that would trigger this method would be:
    #
    # foo = 5
    # case foo
    # when 1..100
    #   puts 'In between'
    # else
    #   puts 'Not sure what I got here'
    # end
    #
    # Counts the `else` body.
    #
    # At the end we subtract one statement because the surrounding context was already counted
    # as one (e.g. via `process_def`).
    #
    def process_case(exp, _parent)
      increase_statement_count_by(exp.else_body)
      decrease_statement_count
      process(exp)
    end

    # Handles `when` nodes.
    #
    # An input example that would trigger this method would be:
    #
    # foo = 5
    # case foo
    # when (1..100)
    #   puts 'In between'
    # else
    #   puts 'Not sure what I got here'
    # end
    #
    # Note that input like
    #
    # if foo then :holla else :nope end
    #
    # does not trigger this method.
    #
    # Counts the `when` body.
    #
    def process_when(exp, _parent)
      increase_statement_count_by(exp.body)
      process(exp)
    end

    def context_processor_exists?(name)
      self.class.private_method_defined?(name)
    end

    # :reek:ControlParameter
    def increase_statement_count_by(sexp)
      current_context.statement_counter.increase_by sexp
    end

    def decrease_statement_count
      current_context.statement_counter.decrease_by 1
    end

    # Stores a reference to the current context, creates a nested new one,
    # yields to the given block and then restores the previous context.
    #
    # @param klass [Context::*Context] - context class
    # @param args - arguments for the class initializer
    # @yield block
    #
    def inside_new_context(klass, *args)
      new_context = append_new_context(klass, *args)

      orig, self.current_context = current_context, new_context
      yield
      self.current_context = orig
    end

    # Appends a new child context to the current context but does not change
    # the current context.
    #
    # @param klass [Context::*Context] - context class
    # @param args - arguments for the class initializer
    #
    # @return [Context::*Context] - the context that was appended
    #
    def append_new_context(klass, *args)
      klass.new(*args).tap do |new_context|
        new_context.register_with_parent(current_context)
      end
    end

    def handle_send_for_modules(exp)
      arg_names = exp.args.map { |arg| arg.children.first }
      current_context.track_visibility(exp.name, arg_names)
      register_attributes(exp)
    end

    def handle_send_for_methods(exp)
      append_new_context(Context::SendContext, exp, exp.name)
      current_context.record_call_to(exp)
    end

    def register_attributes(exp)
      return unless exp.attribute_writer?
      klass = current_context.attribute_context_class
      exp.args.each do |arg|
        append_new_context(klass, arg, exp)
      end
    end
  end
end
