# frozen_string_literal: true
module Reek
  module AST
    module SexpExtensions
      # Utility methods for :casgn nodes.
      module CasgnNode
        def assignment
          children[2]
        end

        def class_creation?
          assignment.respond_to?(:name) &&
            assignment.name == :new &&
              assignment.receiver.name == "Class"
        end
      end
    end
  end
end
