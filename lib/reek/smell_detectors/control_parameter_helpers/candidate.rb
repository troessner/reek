# frozen_string_literal: true

module Reek
  module SmellDetectors
    module ControlParameterHelpers
      #
      # Collects information about a single control parameter.
      #
      class Candidate
        #
        # @param parameter [Symbol] the parameter name
        # @param occurrences [Array<Reek::AST::Node>] the occurrences of the ControlParameter smell
        #   e.g. [s(:lvar, :bravo), s(:lvar, :bravo)]
        #
        def initialize(parameter, occurrences)
          @parameter = parameter
          @occurrences = occurrences
        end

        def smells?
          occurrences.any?
        end

        def lines
          occurrences.map(&:line)
        end

        def name
          parameter.to_s
        end

        private

        attr_reader :occurrences, :parameter
      end
    end
  end
end
