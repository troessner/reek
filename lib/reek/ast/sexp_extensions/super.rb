module Reek
  module AST
    module SexpExtensions
      # Utility methods for :super nodes.
      module SuperNode
        def method_name
          :super
        end
      end

      ZsuperNode = SuperNode
    end
  end
end
