module Reek
  module Core

    #
    # A context wrapper representing the root of an abstract syntax tree.
    #
    class StopContext

      def initialize
        @name = ''
      end

      def method_missing(method, *args)
        nil
      end

      def config_for(_)
        {}
      end

      def count_statements(num)
        0
      end

      def full_name
        ''
      end
    end
  end
end
