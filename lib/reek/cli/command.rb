module Reek
  module CLI
    #
    # Base class for all commands
    #
    # @api private
    class Command
      attr_reader :options

      def initialize(options)
        @options = options
      end
    end
  end
end
