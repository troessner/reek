# frozen_string_literal: true

module Reek
  module SmellDetectors
    module ControlParameterHelpers
      # Finds conditional nodes and the associated conditions
      module ConditionFinder
        CONDITIONAL_NODE_TYPES = [:if, :case, :and, :or].freeze

        #
        # @return [Reek::AST::Node] the condition that is associated with a conditional node.
        #   For instance, this code
        #
        #     if charlie(bravo) then delta end
        #
        #   would be parsed into this AST:
        #
        #     s(:if,
        #       s(:send, nil, :charlie,
        #         s(:lvar, :bravo)),
        #       s(:send, nil, :delta), nil)
        #
        #   so in this case we would return this
        #
        #     s(:send, nil, :charlie,
        #       s(:lvar, :bravo))
        #
        #   as condition.
        #
        def condition
          return unless CONDITIONAL_NODE_TYPES.include?(node.type)
          node.condition
        end

        #
        # @return [Array<Reek::AST::Node>] the conditional nodes scoped below the current node
        #
        def conditional_nodes
          node.body_nodes(CONDITIONAL_NODE_TYPES)
        end
      end
    end
  end
end
