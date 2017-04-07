# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :sym nodes.
      module SymNode
        def name
          children.first
        end

        def full_name(outer)
          "#{outer}##{name}"
        end
      end
    end
  end
end
