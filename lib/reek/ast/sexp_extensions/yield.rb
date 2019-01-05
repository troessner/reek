# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :yield nodes.
      module YieldNode
        def args
          children
        end
      end
    end
  end
end
