
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

      def initialize(outer, exp)
        @outer = outer
        @exp = exp
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
        candidates.any? { |str| /#{str}/ =~ my_fq_name }
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

      def config_for(detector_class)
        outer_config_for(detector_class).merge(
          config[detector_class.smell_type] || {})
      end

      private

      def config
        @config ||= if @exp
                      Source::CodeComment.new(@exp.comments || '').config
                    else
                      {}
                    end
      end

      def outer_config_for(detector_class)
        @outer ? @outer.config_for(detector_class) : {}
      end
    end
  end
end
