require_relative 'sexp_node'
require_relative '../core/reference_collector'

module Reek
  module Sexp
    #
    # Extension modules providing utility methods to ASTNode objects, depending
    # on their type.
    #
    module SexpExtensions
      # Base module for utility methods for argument nodes.
      module ArgNodeBase
        def name
          children.first
        end

        # Other is a symbol?
        def ==(other)
          name == other
        end

        def marked_unused?
          plain_name.start_with?('_')
        end

        def plain_name
          name.to_s
        end

        def block?
          false
        end

        def optional_argument?
          false
        end

        def anonymous_splat?
          false
        end

        def components
          [self]
        end
      end

      # Utility methods for :arg nodes.
      module ArgNode
        include ArgNodeBase
      end

      # Utility methods for :kwarg nodes.
      module KwargNode
        include ArgNodeBase
      end

      # Utility methods for :optarg nodes.
      module OptargNode
        include ArgNodeBase

        def optional_argument?
          true
        end
      end

      # Utility methods for :kwoptarg nodes.
      module KwoptargNode
        include ArgNodeBase

        def optional_argument?
          true
        end
      end

      # Utility methods for :blockarg nodes.
      module BlockargNode
        include ArgNodeBase
        def block?
          true
        end
      end

      # Utility methods for :restarg nodes.
      module RestargNode
        include ArgNodeBase
        def anonymous_splat?
          !name
        end
      end

      # Utility methods for :kwrestarg nodes.
      module KwrestargNode
        include ArgNodeBase
        def anonymous_splat?
          !name
        end
      end

      # Utility methods for :shadowarg nodes.
      module ShadowargNode
        include ArgNodeBase
      end

      # Base module for utility methods for nodes that can contain argument
      # nodes nested through :mlhs nodes.
      module NestedAssignables
        def components
          children.flat_map(&:components)
        end
      end

      # Utility methods for :args nodes.
      module ArgsNode
        include NestedAssignables
      end

      # Utility methods for :mlhs nodes.
      module MlhsNode
        include NestedAssignables
      end

      # Base module for utility methods for :and and :or nodes.
      module LogicOperatorBase
        def condition() self[1] end

        def body_nodes(type, ignoring = [])
          self[2].find_nodes type, ignoring
        end
      end

      # Utility methods for :and nodes.
      module AndNode
        include LogicOperatorBase
      end

      # Utility methods for :or nodes.
      module OrNode
        include LogicOperatorBase
      end

      # Utility methods for :attrasgn nodes.
      module AttrasgnNode
        def args() self[3] end
      end

      # Utility methods for :case nodes.
      module CaseNode
        def condition() self[1] end

        def body_nodes(type, ignoring = [])
          children[1..-1].compact.flat_map { |child| child.find_nodes(type, ignoring) }
        end

        def else_body
          children.last
        end
      end

      # Utility methods for :when nodes.
      module WhenNode
        def condition_list
          children[0..-2]
        end

        def body
          children.last
        end
      end

      # Utility methods for :send nodes.
      module SendNode
        def receiver() self[1] end
        def method_name() self[2] end
        def args() self[3..-1] end

        def participants
          ([receiver] + args).compact
        end

        def arg_names
          args.map { |arg| arg[1] }
        end
      end

      # Base module for utility methods for nodes representing variables.
      module VariableBase
        def name() self[1] end
      end

      # Utility methods for :cvar nodes.
      module CvarNode
        include VariableBase
      end

      CvasgnNode = CvarNode
      CvdeclNode = CvarNode

      # Utility methods for :ivar nodes.
      module IvarNode
        include VariableBase
      end

      # Utility methods for :ivasgn nodes.
      module IvasgnNode
        include VariableBase
      end

      # Utility methods for :lvar nodes.
      module LvarNode
        include VariableBase
        # TODO: Replace with name().
        def var_name() self[1] end
      end

      LvasgnNode = LvarNode

      # Base module for utility methods for :def and :defs nodes.
      module MethodNodeBase
        def arguments
          parameters.reject(&:block?)
        end

        def arg_names
          arguments.map(&:name)
        end

        def parameters
          argslist.components
        end

        def parameter_names
          parameters.map(&:name)
        end

        def name_without_bang
          name.to_s.chop
        end

        def ends_with_bang?
          name[-1] == '!'
        end

        def body_nodes(types, ignoring = [])
          if body
            body.find_nodes(types, ignoring)
          else
            []
          end
        end
      end

      # Utility methods for :def nodes.
      module DefNode
        def name() self[1] end
        def argslist() self[2] end

        def body
          self[3]
        end
        include MethodNodeBase
        def full_name(outer)
          prefix = outer == '' ? '' : "#{outer}#"
          "#{prefix}#{name}"
        end

        def depends_on_instance?
          Core::ReferenceCollector.new(self).num_refs_to_self > 0
        end
      end

      # Utility methods for :defs nodes.
      module DefsNode
        def receiver() self[1] end
        def name() self[2] end
        def argslist() self[3] end

        def body
          self[4]
        end

        include MethodNodeBase
        def full_name(outer)
          prefix = outer == '' ? '' : "#{outer}#"
          "#{prefix}#{SexpFormatter.format(receiver)}.#{name}"
        end

        def depends_on_instance?
          false
        end
      end

      # Utility methods for :if nodes.
      module IfNode
        def condition() self[1] end

        def body_nodes(type, ignoring = [])
          children[1..-1].compact.flat_map { |child| child.find_nodes(type, ignoring) }
        end
      end

      # Utility methods for :block nodes.
      module BlockNode
        def call() self[1] end
        def args() self[2] end
        def block() self[3] end
        def parameters() self[2] || [] end

        def parameter_names
          parameters[1..-1].to_a
        end
      end

      # Utility methods for :lit nodes.
      module LitNode
        def value() self[1] end
      end

      # Utility methods for :const nodes.
      module ConstNode
        def simple_name
          children.last
        end
      end

      # Utility methods for :module nodes.
      module ModuleNode
        def name() self[1] end

        def simple_name
          name.is_a?(AST::Node) ? name.simple_name : name
        end

        def full_name(outer)
          prefix = outer == '' ? '' : "#{outer}::"
          "#{prefix}#{text_name}"
        end

        def text_name
          SexpFormatter.format(name)
        end
      end

      # Utility methods for :class nodes.
      module ClassNode
        include ModuleNode
        def superclass() self[2] end
      end

      # Utility methods for :yield nodes.
      module YieldNode
        def args() self[1..-1] end

        def arg_names
          args.map { |arg| arg[1] }
        end
      end

      # Utility methods for :super nodes.
      module SuperNode
        def method_name
          :super
        end
      end

      ZsuperNode = SuperNode
    end
  end
end
