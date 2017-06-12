# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :begin nodes.
      module BeginNode
        # The special type :begin exists primarily to contain more statements.
        # Therefore, this method overrides the default implementation to return
        # this node's children.
        def statements
          children
        end
      end
    end
  end
end
