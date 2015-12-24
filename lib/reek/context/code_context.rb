require_relative '../code_comment'
require_relative '../ast/object_refs'
require_relative 'visibility_tracker'
require_relative 'statement_counter'

require 'forwardable'
require 'private_attr/everywhere'

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
      extend Forwardable
      delegate each_node: :exp
      delegate %i(name type) => :exp
      delegate %i(visibility visibility= non_public_visibility?) => :visibility_tracker

      attr_reader :children, :context, :exp, :statement_counter, :visibility_tracker
      private_attr_reader :refs

      # Initializes a new CodeContext.
      #
      # @param context [CodeContext, nil] The parent context
      # @param exp [Reek::AST::Node] The code described by this context
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
      # Next, it instantiates a {ModuleContext}, with +context+ being the
      # {RootContext} just created, and +exp+ looking like this:
      #
      #  (class
      #    (const nil :Omg) nil
      #    (def :foo
      #      (args
      #        (arg :x))
      #      (send nil :puts
      #        (lvar :x))))
      #
      # Finally, {ContextBuilder} will instantiate a {MethodContext}. This time,
      # +context+ is the {ModuleContext} created above, and +exp+ is:
      #
      #   (def :foo
      #     (args
      #       (arg :x))
      #     (send nil :puts
      #       (lvar :x)))
      def initialize(context, exp)
        @context            = context
        @exp                = exp
        @children           = []
        @visibility_tracker = VisibilityTracker.new
        @statement_counter  = StatementCounter.new
        @refs               = AST::ObjectRefs.new
      end

      # Iterate over each AST node (see `Reek::AST::Node`) of a given type for the current expression.
      #
      # @param type [Symbol] the type of the nodes we are looking for, e.g. :defs.
      # @yield block that is executed for every node.
      #
      def local_nodes(type, &blk)
        each_node(type, [:casgn, :class, :module], &blk)
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

      alias_method :parent, :context

      # Register a child context. The child's parent context should be equal to
      # the current context.
      #
      # This makes the current context responsible for setting the child's
      # visibility.
      #
      # @param child [CodeContext] the child context to register
      def append_child_context(child)
        visibility_tracker.set_child_visibility(child)
        children << child
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
        exp.full_name(context ? context.full_name : '')
      end

      def config_for(detector_class)
        context_config_for(detector_class).merge(
          configuration_via_code_commment[detector_class.smell_type] || {})
      end

      def track_visibility(visibility, names)
        visibility_tracker.track_visibility children: children,
                                            visibility: visibility,
                                            names: names
      end

      def number_of_statements
        statement_counter.value
      end

      private

      def configuration_via_code_commment
        @configuration_via_code_commment ||= CodeComment.new(full_comment).config
      end

      def full_comment
        exp.full_comment || ''
      end

      def context_config_for(detector_class)
        context ? context.config_for(detector_class) : {}
      end
    end
  end
end
