class Module

  def const_or_nil(sym)
    const_defined?(sym) ? const_get(sym) : nil
  end
end

module Reek
  
  #
  # Superclass for all types of source code context. Each instance represents
  # a code element of some kind, and each provides behaviour relevant to that
  # code element. CodeContexts form a tree in the same way the code does,
  # with each context holding a reference to a unique outer context.
  #
  class CodeContext

    attr_reader :name

    def initialize(outer, exp)
      @outer = outer
      @exp = exp
      @myself = nil
    end

    def local_nodes(type, &blk)
      each_node(type, [:class, :module], &blk)
    end

    def each_node(type, ignoring, &blk)
      if block_given?
        @exp.look_for(type, ignoring, &blk)
      else
        result = []
        @exp.look_for(type, ignoring) {|exp| result << exp}
        result
      end
    end

    # SMELL: Temporary Field -- @name isn't always initialized
    def matches?(strings)
      me = @name.to_s
      strings.any? do |str|
        re = /#{str}/
        re === me or re === self.to_s
      end
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

    def outer_name
      "#{@name}/"
    end

    def to_s
      "#{@outer.outer_name}#{@name}"
    end
  end
end
