# frozen_string_literal: true
module Reek
  module AST
    module SexpExtensions
      # Utility methods for :const nodes.
      module ConstNode
        CORE_CLASSES = ["Array", "Hash", "String"].freeze

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

        def core_class?
          CORE_CLASSES.include?(name)
        end
      end
    end
  end
end
