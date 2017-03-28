# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :if nodes.
      module IfNode
        def condition
          children.first
        end

        def body_nodes(type, ignoring = [])
          children[1..-1].compact.flat_map { |child| child.find_nodes(type, ignoring) }
        end
      end
    end
  end
end
