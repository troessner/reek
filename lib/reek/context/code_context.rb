require_relative '../code_comment'
require_relative '../ast/object_refs'

module Reek
  # @api private
  module Context
    #
    # Superclass for all types of source code context. Each instance represents
    # a code element of some kind, and each provides behaviour relevant to that
    # code element. CodeContexts form a tree in the same way the code does,
    # with each context holding a reference to a unique outer context.
    #
    # @api private
    class CodeContext
      attr_reader :exp
      attr_reader :num_statements
      attr_reader :children
      attr_reader :visibility

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
      # The {TreeWalker} object first instantiates a {RootContext}, which has no parent.
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
      # Finally, {TreeWalker} will instantiate a {MethodContext}. This time,
      # +context+ is the {ModuleContext} created above, and +exp+ is:
      #
      #   (def :foo
      #     (args
      #       (arg :x))
      #     (send nil :puts
      #       (lvar :x)))
      def initialize(context, exp)
        @context    = context
        @exp        = exp
        @visibility = :public
        @children   = []

        @num_statements = 0
        @refs = AST::ObjectRefs.new
      end

      # Register a child context. The child's parent context should be equal to
      # the current context.
      #
      # This makes the current context responsible for setting the child's
      # visibility.
      #
      # @param child [CodeContext] the child context to register
      def append_child_context(child)
        child.visibility = tracked_visibility
        children << child
      end

      def count_statements(num)
        self.num_statements += num
      end

      def record_call_to(exp)
        receiver = exp.receiver
        type = receiver ? receiver.type : :self
        case type
        when :lvar, :lvasgn
          unless exp.object_creation_call?
            refs.record_reference_to(receiver.name, line: exp.line)
          end
        when :self
          refs.record_reference_to(:self, line: exp.line)
        end
      end

      def record_use_of_self
        refs.record_reference_to(:self)
      end

      def name
        exp.name
      end

      def local_nodes(type, &blk)
        each_node(type, [:casgn, :class, :module], &blk)
      end

      def each_node(type, ignoring, &blk)
        exp.each_node(type, ignoring, &blk)
      end

      def matches?(candidates)
        my_fq_name = full_name
        candidates.any? do |candidate|
          candidate = Regexp.quote(candidate) if candidate.is_a?(String)
          /#{candidate}/ =~ my_fq_name
        end
      end

      def num_methods
        0
      end

      def full_name
        exp.full_name(context ? context.full_name : '')
      end

      def config_for(detector_class)
        context_config_for(detector_class).merge(
          config[detector_class.smell_type] || {})
      end

      # Handle the effects of a visibility modifier.
      #
      # @example Setting the current visibility
      #   track_visibility :public
      #
      # @example Modifying the visibility of existing children
      #   track_visibility :private, [:hide_me, :implementation_detail]
      #
      # @param visibility [Symbol]
      # @param names [Array<Symbol>]
      def track_visibility(visibility, names = [])
        if names.any?
          children.each do |child|
            child.visibility = visibility if names.include? child.name
          end
        else
          self.tracked_visibility = visibility
        end
      end

      def type
        exp.type
      end

      # Iterate over +self+ and child contexts.
      def each(&block)
        yield self
        children.each do |child|
          child.each(&block)
        end
      end

      protected

      attr_writer :num_statements, :visibility

      private

      private_attr_writer :tracked_visibility
      private_attr_reader :context, :refs

      def tracked_visibility
        @tracked_visibility ||= :public
      end

      def config
        @config ||= if exp
                      CodeComment.new(exp.full_comment || '').config
                    else
                      {}
                    end
      end

      def context_config_for(detector_class)
        context ? context.config_for(detector_class) : {}
      end
    end
  end
end
