module Reek
  # @api private
  module Context
    #
    # A context wrapper representing the root of an abstract syntax tree.
    #
    # @api private
    class RootContext
      def initialize
        @name = ''
      end

      def method_missing(_method, *_args)
        nil
      end

      def config_for(_)
        {}
      end

      def count_statements(_num)
        0
      end

      def full_name
        ''
      end
    end
  end
end
