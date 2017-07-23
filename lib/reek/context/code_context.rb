# frozen_string_literal: true

require_relative '../code_comment'
require_relative '../ast/object_refs'
require_relative 'statement_counter'

require 'forwardable'

module Reek
  module Context
    #
    # Superclass for all types of source code context. Each instance represents
    # a code element of some kind, and each provides behaviour relevant to that
    # code element. CodeContexts form a tree in the same way the code does,
    # with each context holding a reference to a unique outer context.
    #
    # :reek:TooManyMethods: { max_methods: 19 }
    # :reek:TooManyInstanceVariables: { max_instance_variables: 8 }
    class CodeContext
      include Enumerable
      extend Forwardable
      delegate each_node: :exp
      delegate [:name, :type] => :exp

      attr_reader :children, :parent, :exp, :statement_counter

      # Initializes a new CodeContext.
      #
      # @param exp [Reek::AST::Node] The code described by this context
      def initialize(exp)
        @exp                = exp
        @children           = []
        @statement_counter  = StatementCounter.new
        @refs               = AST::ObjectRefs.new
      end

      # Iterate over each AST node (see `Reek::AST::Node`) of a given type for the current expression.
      #
      # @param type [Symbol] the type of the nodes we are looking for, e.g. :defs.
      # @yield block that is executed for every node.
      #
      def local_nodes(type, ignored = [], &blk)
        ignored += [:casgn, :class, :module]
        each_node(type, ignored, &blk)
      end

      # Iterate over `self` and child contexts.
      # The main difference (among others) to `each_node` is that we are traversing
      # `CodeContexts` here, not AST nodes (see `Reek::AST::Node`).
      #
      # @yield block that is executed for every node.
      # @return [Enumerator]
      #
      def each(&block)
        return enum_for(:each) unless block_given?

        yield self
        children.each do |child|
          child.each(&block)
        end
      end

      # Link the present context to its parent.
      #
      # @param parent [Reek::AST::Node] The parent context of the code described by this context
      #
      # For example, given the following code:
      #
      #   class Omg
      #     def foo(x)
      #       puts x
      #     end
      #   end
      #
      # The {ContextBuilder} object first instantiates a {RootContext}, which has no parent.
      #
      # Next, it instantiates a {ModuleContext}, with +exp+ looking like this:
      #
      #  (class
      #    (const nil :Omg) nil
      #    (def :foo
      #      (args
      #        (arg :x))
      #      (send nil :puts
      #        (lvar :x))))
      #
      # It will then call #register_with_parent on the {ModuleContext}, passing
      # in the parent {RootContext}.
      #
      # Finally, {ContextBuilder} will instantiate a {MethodContext}. This time,
      # +exp+ is:
      #
      #   (def :foo
      #     (args
      #       (arg :x))
      #     (send nil :puts
      #       (lvar :x)))
      #
      # Then it will call #register_with_parent on the {MethodContext}, passing
      # in the parent {ModuleContext}.
      def register_with_parent(parent)
        @parent = parent.append_child_context(self) if parent
      end

      # Register a context as a child context of this context. This is
      # generally used by a child context to register itself with its parent.
      #
      # @param child [CodeContext] the child context to register
      def append_child_context(child)
        children << child
        self
      end

      # :reek:TooManyStatements: { max_statements: 6 }
      # :reek:FeatureEnvy
      def record_call_to(exp)
        receiver = exp.receiver
        type = receiver ? receiver.type : :self
        line = exp.line
        case type
        when :lvar, :lvasgn
          unless exp.object_creation_call?
            refs.record_reference(name: receiver.name, line: line)
          end
        when :self
          refs.record_reference(name: :self, line: line)
        end
      end

      def record_use_of_self
        refs.record_reference(name: :self)
      end

      def matches?(candidates)
        my_fq_name = full_name
        candidates.any? do |candidate|
          candidate = Regexp.quote(candidate) if candidate.is_a?(String)
          /#{candidate}/ =~ my_fq_name
        end
      end

      def full_name
        exp.full_name(parent ? parent.full_name : '')
      end

      def config_for(detector_class)
        parent_config_for(detector_class).merge(
          configuration_via_code_commment[detector_class.smell_type] || {})
      end

      def number_of_statements
        statement_counter.value
      end

      def singleton_method?
        false
      end

      def instance_method?
        false
      end

      def apply_current_visibility(_current_visibility)
        # Nothing to do by default
      end

      private

      attr_reader :refs

      def configuration_via_code_commment
        @configuration_via_code_commment ||= CodeComment.new(comment: full_comment,
                                                             line: exp.line,
                                                             source: exp.source).config
      end

      def full_comment
        exp.full_comment || ''
      end

      def parent_config_for(detector_class)
        parent ? parent.config_for(detector_class) : {}
      end
    end
  end
end
