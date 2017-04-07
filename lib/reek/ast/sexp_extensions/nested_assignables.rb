# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
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
    end
  end
end
