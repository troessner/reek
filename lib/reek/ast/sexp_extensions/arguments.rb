# frozen_string_literal: true

module Reek
  module AST
    module SexpExtensions
      # Base module for utility methods for argument nodes.
      module ArgNodeBase
        def name
          children.first
        end

        def marked_unused?
          plain_name.start_with?('_')
        end

        def plain_name
          name.to_s
        end

        def block?
          false
        end

        def optional_argument?
          false
        end

        def anonymous_splat?
          false
        end

        def components
          [self]
        end
      end

      # Utility methods for :arg nodes.
      module ArgNode
        include ArgNodeBase
      end

      # Utility methods for :kwarg nodes.
      module KwargNode
        include ArgNodeBase
      end

      # Utility methods for :optarg nodes.
      module OptargNode
        include ArgNodeBase

        def optional_argument?
          true
        end
      end

      # Utility methods for :kwoptarg nodes.
      module KwoptargNode
        include ArgNodeBase

        def optional_argument?
          true
        end
      end

      # Utility methods for :blockarg nodes.
      module BlockargNode
        include ArgNodeBase

        def block?
          true
        end
      end

      # Utility methods for :restarg nodes.
      module RestargNode
        include ArgNodeBase

        def anonymous_splat?
          !name
        end
      end

      # Utility methods for :kwrestarg nodes.
      module KwrestargNode
        include ArgNodeBase

        def anonymous_splat?
          !name
        end
      end

      # Utility methods for :shadowarg nodes.
      module ShadowargNode
        include ArgNodeBase
      end
    end
  end
end
