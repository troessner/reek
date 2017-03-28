# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :block nodes.
      module BlockNode
        def call
          children.first
        end

        def args
          children[1]
        end

        def block
          children[2]
        end

        def parameters
          children[1] || []
        end

        def parameter_names
          parameters.children
        end

        def simple_name
          :block
        end

        def without_block_arguments?
          args.components.empty?
        end
      end
    end
  end
end
