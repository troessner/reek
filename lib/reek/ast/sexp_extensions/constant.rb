# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Utility methods for :const nodes.
      module ConstNode
        # TODO: name -> full_name, simple_name -> name
        def name
          if namespace
            "#{namespace.format_to_ruby}::#{simple_name}"
          else
            simple_name.to_s
          end
        end

        def simple_name
          children.last
        end

        def namespace
          children.first
        end
      end
    end
  end
end
