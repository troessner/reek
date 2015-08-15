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

      private

      private_attr_reader :options
    end
  end
end
