# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :when nodes.
      module WhenNode
        def condition_list
          children[0..-2]
        end

        def body
          children.last
        end
      end
    end
  end
end
