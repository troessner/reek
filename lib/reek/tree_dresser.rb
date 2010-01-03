module Reek

  #
  # Extensions to +Sexp+ to allow +CodeParser+ to navigate the abstract
  # syntax tree more easily.
  #
  module SexpNode
    def is_language_node?
      first.class == Symbol
    end

    def has_type?(type)
      is_language_node? and first == type
    end

    #
    # Carries out a depth-first traversal of this syntax tree, yielding
    # every Sexp of type +target_type+. The traversal ignores any node
    # whose type is listed in the Array +ignoring+.
    #
    def look_for(target_type, ignoring, &blk)
      each do |elem|
        if Sexp === elem then
          elem.look_for(target_type, ignoring, &blk) unless ignoring.include?(elem.first)
        end
      end
      blk.call(self) if first == target_type
    end
  end

  module SexpExtensions
    module CaseNode
      def condition
        self[1]
      end
    end

    module CallNode
      def receiver() self[1] end
      def method_name() self[2] end
      def args() self[3] end
      def arg_names
        args[1..-1].map {|arg| arg[1]}
      end
    end

    module CvarNode
      def name() self[1] end
    end

    CvasgnNode = CvarNode
    CvdeclNode = CvarNode

    module DefnNode
      def method_name() self[1] end
      def parameters() self[2] end
    end

    module IfNode
      def condition
        self[1]
      end
    end

    module IterNode
      def call() self[1] end
      def args() self[2] end
      def block() self[3] end
    end

    module YieldNode
      def args() self[1..-1] end
      def arg_names
        args.map {|arg| arg[1]}
      end
    end
  end

  #
  # Adorns an abstract syntax tree with mix-in modules to make accessing
  # the tree more understandable and less implementation-dependent.
  #
  class TreeDresser

    def dress(sexp)
      sexp.extend(SexpNode)
      module_name = extensions_for(sexp.sexp_type)
      if Reek::SexpExtensions.const_defined?(module_name)
        sexp.extend(Reek::SexpExtensions.const_get(module_name))
      end
      sexp[0..-1].each { |sub| dress(sub) if Array === sub }
      sexp
    end

    def extensions_for(node_type)
      "#{node_type.to_s.capitalize}Node"
    end
  end
end
