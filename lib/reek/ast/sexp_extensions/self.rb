# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :self nodes.
      module SelfNode
        def name
          :self
        end
      end
    end
  end
end
