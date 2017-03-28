# frozen_string_literal: true

module Reek
  module CLI
    module Command
      #
      # Base class for all commands
      #
      class BaseCommand
        def initialize(options:, sources:, configuration:)
          @options = options
          @sources = sources
          @configuration = configuration
        end

        private

        attr_reader :options, :sources, :configuration

        def smell_names
          @smell_names ||= options.smells_to_detect
        end
      end
    end
  end
end
