
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

      def initialize(outer, exp, scope_connector = '')
        @outer = outer
        @exp = exp
        @scope_connector = scope_connector
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

      # SMELL: Temporary Field -- @name isn't always initialized
      def matches?(candidates)
        my_short_name = name.to_s
        return true if candidates.any? {|str| /#{str}/ === my_short_name }
        return candidates.any? {|str| /#{str}/ === full_name }
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
        prefix = outer == '' ? '' : "#{outer}#{@scope_connector}"
        "#{prefix}#{name}"
      end
    end
  end
end
