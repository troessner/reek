# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :send nodes.
      module SendNode
        ATTR_DEFN_METHODS = [:attr_writer, :attr_accessor].freeze

        def receiver
          children.first
        end

        def name
          children[1]
        end

        def args
          children[2..]
        end

        def participants
          ([receiver] + args).compact
        end

        def module_creation_call?
          return true if object_creation_call? && module_creation_receiver?
          return true if data_definition_call? && data_definition_receiver?

          false
        end

        def object_creation_call?
          name == :new
        end

        def attribute_writer?
          ATTR_DEFN_METHODS.include?(name) ||
            attr_with_writable_flag?
        end

        # Handles the case where we create an attribute writer via:
        # attr :foo, true
        def attr_with_writable_flag?
          name == :attr && args.any? && args.last.type == :true
        end

        private

        def module_creation_receiver?
          const_receiver? && [:Class, :Struct].include?(receiver.simple_name)
        end

        def data_definition_call?
          name == :define
        end

        def data_definition_receiver?
          const_receiver? && receiver.simple_name == :Data
        end

        def const_receiver?
          receiver && receiver.type == :const
        end
      end

      Op_AsgnNode = SendNode
      CSendNode = SendNode
    end
  end
end
