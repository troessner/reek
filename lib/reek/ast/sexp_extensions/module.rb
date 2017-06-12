# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Base module for utility methods for nodes that define constants: module
      # definition, class definition and constant assignment.
      module ConstantDefiningNodeBase
        # The full name of the constant, including the name of any
        # module or class it is nested inside of.
        #
        # For example, given code like this:
        #
        #   module Foo
        #     class Bar::Baz
        #     end
        #   end
        #
        # The full name for the inner class will be 'Foo::Bar::Baz'. To return
        # the correct name, the name of the outer context has to be passed into
        # this method.
        #
        # @param outer [String] full name of the wrapping module or class
        # @return the module's full name
        def full_name(outer)
          [outer, name].reject(&:empty?).join('::')
        end

        # The final section of the module or class name. For example, for a
        # module with name 'Foo::Bar' this will return 'Bar'; for a module with
        # name 'Foo' this will return 'Foo'.
        #
        # @return [String] the final section of the name
        def simple_name
          name.split('::').last
        end
      end

      # Base module for utility methods for module nodes.
      module ModuleNodeBase
        include ConstantDefiningNodeBase

        def name
          children.first.format_to_ruby
        end

        # In the AST, the set of children of a module that a human might identify
        # is coded in three different ways.
        #
        # If there are no children, the last element of the module node is nil,
        # like so:
        #
        #   s(:class,
        #     s(:const, nil, :C),
        #     nil,
        #     nil)
        #
        # If there is one child, the last element of the module node is that
        # child, like so:
        #
        #   s(:class,
        #     s(:const, nil, :C),
        #     nil,
        #     s(:def, :f, s(:args), nil))
        #
        # If there is more than one child, those are wrapped as children in a
        # node of type :begin, like so:
        #
        #   s(:class,
        #     s(:const, nil, :Alfa),
        #     nil,
        #     s(:begin,
        #       s(:def, :bravo, s(:args), nil),
        #       s(:class, s(:const, nil, :Charlie), nil, nil)))
        #
        # This method unifies those three ways to avoid having to handle them
        # differently.
        #
        # @return an array of directly visible children of the module
        #
        def direct_children
          contents = children.last or return []
          contents.statements
        end
      end

      # Utility methods for module definition (:module) nodes.
      module ModuleNode
        include ModuleNodeBase
      end

      # Utility methods for class definition (:class) nodes.
      module ClassNode
        include ModuleNodeBase

        def superclass() children[1] end
      end

      # Utility methods for constant assignment (:casgn) nodes.
      module CasgnNode
        include ConstantDefiningNodeBase

        def defines_module?
          call = constant_definition
          call && call.module_creation_call?
        end

        # Sometimes we assign classes like:
        #
        # Foo = Class.new(Bar)
        #
        # This is mapped into the following expression:
        #
        # s(:casgn, nil :Foo,
        #   s(:send,
        #     s(:const, nil, :Class), :new,
        #     s(:const, nil, :Bar)
        #   )
        # )
        #
        # And we are only looking for s(:const, nil, :Bar)
        #
        def superclass
          return nil unless defines_module?

          constant_definition.args.first if constant_definition.receiver.name == 'Class'
        end

        def name
          children[1].to_s
        end

        # there are two valid forms of the casgn sexp
        # (casgn <namespace> <name> <value>) and
        # (casgn <namespace> <name>) used in or-asgn and mlhs
        #
        # source = "class Hi; THIS ||= 3; end"
        # (class
        #   (const nil :Hi) nil
        #   (or-asgn
        #    (casgn nil :THIS)
        #    (int 3)))
        def value
          children[2]
        end

        private

        # This is the right hand side of a constant
        # assignment.
        #
        # This can be simple:
        #
        # Foo = 23
        #
        # s(:casgn, nil, :Foo,
        #   s(:int, 23))
        #
        # In this cases we do not care and return nil.
        #
        # Or complicated:
        #
        # Iterator = Struct.new :exp do ... end
        #
        # s(:casgn, nil, :Iterator,
        #   s(:block,
        #     s(:send,
        #       s(:const, nil, :Struct), :new,
        #       s(:sym, :exp)
        #     ),
        #     s(:args),
        #     ...
        #   )
        # )
        #
        # In this cases we return the Struct.new part
        #
        def constant_definition
          return nil unless value

          case value.type
          when :block
            call = value.call
            call if call.type == :send
          when :send
            value
          end
        end
      end
    end
  end
end
