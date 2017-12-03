# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :case nodes.
      module CaseNode
        def condition
          children.first
        end

        def body_nodes(type, ignoring = [])
          children[1..-1].compact.flat_map { |child| child.each_node(type, ignoring).to_a }
        end

        def else_body
          children.last
        end
      end
    end
  end
end
