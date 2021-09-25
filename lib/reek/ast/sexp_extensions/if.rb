# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :if nodes.
      module IfNode
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
          children.first
        end

        # @quality :reek:FeatureEnvy
        def body_nodes(type, ignoring = [])
          children[1..].compact.flat_map do |child|
            if ignoring.include? child.type
              []
            else
              child.each_node(type, ignoring | type).to_a
            end
          end
        end
      end
    end
  end
end
