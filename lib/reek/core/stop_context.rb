module Reek
  module Core
    #
    # A context wrapper representing the root of an abstract syntax tree.
    #
    class StopContext
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
