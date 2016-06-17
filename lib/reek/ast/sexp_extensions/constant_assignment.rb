# frozen_string_literal: true
module Reek
  module AST
    module SexpExtensions
      # Utility methods for :casgn nodes.
      module CasgnNode
        def send_expression
          children[2]
        end

        def ancestor
          send_expression.value_assigned
        end

        def class_creation?
          send_expression.respond_to?(:name) &&
            send_expression.name == :new &&
              send_expression.receiver.name == "Class"
        end
      end
    end
  end
end
