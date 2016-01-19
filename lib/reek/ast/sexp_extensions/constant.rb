module Reek
  module AST
    module SexpExtensions
      # Utility methods for :const nodes.
      module ConstNode
        def full_name
          namespace = children.first
          if namespace
            "#{namespace.full_name}::#{simple_name}"
          else
            simple_name.to_s
          end
        end

        def simple_name
          children.last
        end

        def name
          full_name
        end
      end

      # Utility methods for :cbase nodes.
      module CbaseNode
        def full_name
          ''
        end
      end
    end
  end
end
