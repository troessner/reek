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
          children[2..-1]
        end

        def participants
          ([receiver] + args).compact
        end

        def module_creation_call?
          object_creation_call? && module_creation_receiver?
        end

        def module_creation_receiver?
          receiver &&
            receiver.type == :const &&
            [:Class, :Struct].include?(receiver.simple_name)
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
      end

      Op_AsgnNode = SendNode
      CSendNode = SendNode
    end
  end
end
