
module Reek
  module Core

    #
    # Superclass for all types of source code context. Each instance represents
    # a code element of some kind, and each provides behaviour relevant to that
    # code element. CodeContexts form a tree in the same way the code does,
    # with each context holding a reference to a unique outer context.
    #
    class CodeContext

      attr_reader :exp, :config

      def initialize(outer, exp)
        @outer = outer
        @exp = exp
        @config = local_config
      end

      def name
        @exp.name
      end

      def local_nodes(type, &blk)
        each_node(type, [:class, :module], &blk)
      end

      def each_node(type, ignoring, &blk)
        @exp.each_node(type, ignoring, &blk)
      end

      def matches?(candidates)
        my_fq_name = full_name
        candidates.any? {|str| /#{str}/ === my_fq_name }
      end

      #
      # Bounces messages up the context tree to the first enclosing context
      # that knows how to deal with the request.
      #
      def method_missing(method, *args)
        @outer.send(method, *args)
      end

      def num_methods
        0
      end

      def full_name
        outer = @outer ? @outer.full_name : ''
        exp.full_name(outer)
      end

      def local_config
        return Hash.new if @exp.nil?
        config = Source::CodeComment.new(@exp.comments || '').config
        return config unless @outer
        @outer.config.deep_copy.adopt!(config)
        # no tests for this -----^
      end
    end
  end
end
