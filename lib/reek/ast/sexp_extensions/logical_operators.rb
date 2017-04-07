# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Base module for utility methods for :and and :or nodes.
      module LogicOperatorBase
        def condition
          children.first
        end

        def body_nodes(type, ignoring = [])
          children[1].find_nodes type, ignoring
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
    end
  end
end
