module Reek
  module CLI
    #
    # Base class for all commands
    #
    class Command
      def initialize(options)
        @options = options
      end

      private

      attr_reader :options
    end
  end
end
