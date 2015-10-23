module Reek
  module AST
    module SexpExtensions
      # Utility methods for :attrasgn nodes.
      module AttrasgnNode
        def args
          children[2]
        end
      end
    end
  end
end
