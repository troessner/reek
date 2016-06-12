# frozen_string_literal: true
module Reek
  module AST
    module SexpExtensions
      # Utility methods for :casgn nodes.
      module CasgnNode
        def value_assigned
          children[2]
        end

        def class_creation?
          value_assigned.respond_to?(:name) &&
            value_assigned.name == :new &&
              value_assigned.receiver.name == "Class"
        end
      end
    end
  end
end
