module Reek
  module AST
    module SexpExtensions
      # Utility methods for :const nodes.
      module ConstNode
        def simple_name
          children.last
        end
      end
    end
  end
end
