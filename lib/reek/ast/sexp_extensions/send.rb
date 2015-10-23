module Reek
  module AST
    module SexpExtensions
      # Utility methods for :send nodes.
      module SendNode
        VISIBILITY_MODIFIERS = [:private, :public, :protected, :module_function]
        ATTR_DEFN_METHODS = [:attr_writer, :attr_accessor]

        def receiver
          children.first
        end

        def method_name
          children[1]
        end

        def args
          children[2..-1]
        end

        def participants
          ([receiver] + args).compact
        end

        def arg_names
          args.map { |arg| arg.children.first }
        end

        def module_creation_call?
          object_creation_call? && module_creation_receiver?
        end

        def module_creation_receiver?
          receiver && [:Class, :Struct].include?(receiver.simple_name)
        end

        def object_creation_call?
          method_name == :new
        end

        def visibility_modifier?
          VISIBILITY_MODIFIERS.include?(method_name)
        end

        def attribute_writer?
          ATTR_DEFN_METHODS.include?(method_name) ||
            attr_with_writable_flag?
        end

        # Handles the case where we create an attribute writer via:
        # attr :foo, true
        def attr_with_writable_flag?
          method_name == :attr && args.any? && args.last.type == :true
        end
      end

      Op_AsgnNode = SendNode
    end
  end
end
