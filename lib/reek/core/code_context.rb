
module Reek
  module Core
    #
    # Superclass for all types of source code context. Each instance represents
    # a code element of some kind, and each provides behaviour relevant to that
    # code element. CodeContexts form a tree in the same way the code does,
    # with each context holding a reference to a unique outer context.
    #
    class CodeContext
      attr_reader :exp

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
      # the first time this is instantianted from TreeWalker `context` is a StopContext:
      #
      #   #<Reek::Core::StopContext:0x00000002231098 @name="">
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
      #   Reek::Core::ModuleContext
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

      #
      # Bounces messages up the context tree to the first enclosing context
      # that knows how to deal with the request.
      #
      def method_missing(method, *args)
        @context.send(method, *args)
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
                      Core::CodeComment.new(@exp.comments || '').config
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
