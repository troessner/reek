# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Base module for utility methods for nodes representing variables.
      module VariableBase
        def name
          children.first
        end
      end

      # Utility methods for :cvar nodes.
      module CvarNode
        include VariableBase
      end

      # Utility methods for :ivar nodes.
      module IvarNode
        include VariableBase
      end

      # Utility methods for :ivasgn nodes.
      module IvasgnNode
        include VariableBase
      end

      # Utility methods for :lvar nodes.
      module LvarNode
        include VariableBase

        alias var_name name
      end

      # Utility methods for :gvar nodes.
      module GvarNode
        include VariableBase
      end

      LvasgnNode = LvarNode
      CvasgnNode = CvarNode
      CvdeclNode = CvarNode
    end
  end
end
