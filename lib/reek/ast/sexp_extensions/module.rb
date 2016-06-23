# frozen_string_literal: true
module Reek
  module AST
    module SexpExtensions
      # Base module for utility methods for module nodes.
      module ModuleNodeBase
        # The full name of the module or class, including the name of any
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
        # the correct name, the name of the outer context has to be passed into this method.
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

        def name
          children.first.format_to_ruby
        end
      end

      # Utility methods for :module nodes.
      module ModuleNode
        include ModuleNodeBase
      end

      # Utility methods for :class nodes.
      module ClassNode
        include ModuleNodeBase

        def superclass() children[1] end
      end

      # Utility methods for :casgn nodes.
      module CasgnNode
        include ModuleNodeBase

        def defines_module?
          call = constant_definition
          call && call.module_creation_call?
        end

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
            value.call
          when :send
            value
          end
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
          return nil unless constant_definition

          constant_definition.args.first
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
      end
    end
  end
end
