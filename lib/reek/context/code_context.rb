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

      # Initializes a new CodeContext.
      #
      # context - *_context from the `core` namespace
      # exp - Reek::Source::ASTNode
      #
      # Examples:
      #
      # Given something like:
      #
      #   class Omg; def foo(x); puts x; end; end
      #
      # the first time this is instantianted from TreeWalker `context` is a RootContext:
      #
      #   #<Reek::Context::RootContext:0x00000002231098 @name="">
      #
      # and `exp` looks like this:
      #
      #  (class
      #    (const nil :Omg) nil
      #    (def :foo
      #      (args
      #        (arg :x))
      #      (send nil :puts
      #        (lvar :x))))
      #
      # The next time we instantiate a CodeContext via TreeWalker `context` would be:
      #
      #   Reek::Context::ModuleContext
      #
      # and `exp` is:
      #
      # (def :foo
      #   (args
      #     (arg :x))
      #   (send nil :puts
      #     (lvar :x)))
      def initialize(context, exp)
        @context = context
        @exp     = exp

        @num_statements = 0
        @refs = AST::ObjectRefs.new
      end

      def count_statements(num)
        @num_statements += num
      end

      def record_call_to(exp)
        receiver = exp.receiver
        type = receiver ? receiver.type : :self
        case type
        when :lvar, :lvasgn
          unless exp.method_name == :new
            @refs.record_reference_to(receiver.name, line: exp.line)
          end
        when :self
          @refs.record_reference_to(:self, line: exp.line)
        end
      end

      def record_use_of_self
        @refs.record_reference_to(:self)
      end

      def name
        @exp.name
      end

      def local_nodes(type, &blk)
        each_node(type, [:casgn, :class, :module], &blk)
      end

      def each_node(type, ignoring, &blk)
        @exp.each_node(type, ignoring, &blk)
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
        context = @context ? @context.full_name : ''
        exp.full_name(context)
      end

      def config_for(detector_class)
        context_config_for(detector_class).merge(
          config[detector_class.smell_type] || {})
      end

      private

      def config
        @config ||= if @exp
                      CodeComment.new(@exp.full_comment || '').config
                    else
                      {}
                    end
      end

      def context_config_for(detector_class)
        @context ? @context.config_for(detector_class) : {}
      end
    end
  end
end
