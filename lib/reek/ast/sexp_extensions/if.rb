# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :if nodes.
      module IfNode
        def condition
          children.first
        end

        # :reek:FeatureEnvy
        def body_nodes(type, ignoring = [])
          children[1..-1].compact.flat_map do |child|
            if ignoring.include? child.type
              []
            else
              child.each_node(type, ignoring).to_a
            end
          end
        end
      end
    end
  end
end
