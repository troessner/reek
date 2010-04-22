module Reek
  module Source

    #
    # Extensions to +Sexp+ to allow +CodeParser+ to navigate the abstract
    # syntax tree more easily.
    #
    module SexpNode
      def self.format(expr)
        case expr
        when Sexp then expr.format_ruby
        else expr.to_s
        end
      end

      def hash
        self.inspect.hash
      end

      def is_language_node?
        first.class == Symbol
      end

      def has_type?(type)
        is_language_node? and first == type
      end

      def each_node(type, ignoring, &blk)
        if block_given?
          look_for(type, ignoring, &blk)
        else
          result = []
          look_for(type, ignoring) {|exp| result << exp}
          result
        end
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
      def format_ruby
        return self[0].to_s unless Array === self
        Ruby2Ruby.new.process(deep_copy)
      end
      def deep_copy
        YAML::load(YAML::dump(self))
      end
    end

    module SexpExtensions
      module AttrasgnNode
        def args() self[3] end
      end

      module CaseNode
        def condition() self[1] end
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

      module MethodNode
        def arg_names
          unless @args
            @args = argslist[1..-1].reject {|param| Sexp === param or param.to_s =~ /^&/}
          end
          @args
        end
        def parameters()
          unless @params
            @params = argslist.reject {|param| Sexp === param}
          end
          @params
        end
        def parameter_names
          parameters[1..-1]
        end
      end

      module DefnNode
        def name() self[1] end
        def argslist() self[2] end
        def body() self[3] end
        include MethodNode
        def full_name(outer)
          prefix = outer == '' ? '' : "#{outer}#"
          "#{prefix}#{name}"
        end
      end

      module DefsNode
        def receiver() self[1] end
        def name() self[2] end
        def argslist() self[3] end
        def body() self[4] end
        include MethodNode
        def full_name(outer)
          prefix = outer == '' ? '' : "#{outer}#"
          "#{prefix}#{SexpNode.format(receiver)}.#{name}"
        end
      end

      module IfNode
        def condition() self[1] end
      end

      module IterNode
        def call() self[1] end
        def args() self[2] end
        def block() self[3] end
        def parameters() self[2] || [] end
        def parameter_names
          result = parameters
          return case result[0]
          when :lasgn
            [result[1]]
          when :masgn
            result[1][1..-1].map {|lasgn| lasgn[1]}
          else
            []
          end
        end
      end

      module LitNode
        def value() self[1] end
      end

      module ModuleNode
        def name() self[1] end
        def simple_name
          expr = name
          while Sexp === expr and expr[0] == :colon2
            expr = expr[2]
          end
          expr
        end
        def full_name(outer)
          prefix = outer == '' ? '' : "#{outer}::"
          "#{prefix}#{text_name}"
        end
        def text_name
          SexpNode.format(name)
        end
      end

      module ClassNode
        include ModuleNode
        def superclass() self[2] end
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
        if SexpExtensions.const_defined?(module_name)
          sexp.extend(SexpExtensions.const_get(module_name))
        end
        sexp[0..-1].each { |sub| dress(sub) if Array === sub }
        sexp
      end

      def extensions_for(node_type)
        "#{node_type.to_s.capitalize}Node"
      end
    end
  end
end
