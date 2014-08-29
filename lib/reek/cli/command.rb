module Reek
  module Cli

    #
    # Base class for all commands
    #
    class Command
      def initialize(parser)
        @parser = parser
      end
    end
  end
end

