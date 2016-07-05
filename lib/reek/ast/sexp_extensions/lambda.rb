# frozen_string_literal: true
module Reek
  module AST
    module SexpExtensions
      # Utility methods for :lambda nodes.
      module LambdaNode
        def name
          'lambda'
        end

        def module_creation_call?
          false
        end
      end
    end
  end
end
