# frozen_string_literal: true
module Reek
  module CLI
    module Command
      #
      # Base class for all commands
      #
      class BaseCommand
        def initialize(options, sources:)
          @options = options
          @sources = sources
        end

        private

        attr_reader :options, :sources

        def smell_names
          @smell_names ||= options.smells_to_detect
        end
      end
    end
  end
end
