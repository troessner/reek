# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :super nodes.
      module SuperNode
        def name
          :super
        end
      end

      ZsuperNode = SuperNode
    end
  end
end
