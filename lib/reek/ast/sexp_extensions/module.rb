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
          SexpFormatter.format(children.first)
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
          return false unless value
          call = case value.type
                 when :block
                   value.call
                 when :send
                   value
                 end
          call && call.module_creation_call?
        end

        def name
          SexpFormatter.format(children[1])
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
