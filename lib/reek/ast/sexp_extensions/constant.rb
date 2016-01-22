module Reek
  module AST
    module SexpExtensions
      # Utility methods for :const nodes.
      module ConstNode
        def name
          namespace = children.first
          if namespace
            "#{namespace.format_to_ruby}::#{simple_name}"
          else
            simple_name.to_s
          end
        end

        def simple_name
          children.last
        end
      end
    end
  end
end
