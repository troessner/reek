require 'private_attr/everywhere'

module Reek
  module CLI
    #
    # Base class for all commands
    #
    class Command
      def initialize(options)
        @options = options
      end

      private_attr_reader :options
    end
  end
end
