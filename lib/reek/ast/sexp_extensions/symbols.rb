# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :sym nodes.
      module SymNode
        def name
          children.first
        end

        def ends_with_bang?
          name[-1] == '!'
        end

        def full_name(outer)
          "#{outer}##{name}"
        end

        def arg_names
          []
        end
      end
    end
  end
end
