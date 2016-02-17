module Reek
  module CLI
    module Command
      #
      # Base class for all commands
      #
      class BaseCommand
        def initialize(options)
          @options = options
        end

        private

        attr_reader :options

        def smell_names
          @smell_names ||= options.smells_to_detect
        end

        def sources
          @sources ||= options.sources
        end
      end
    end
  end
end
