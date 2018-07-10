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
        # @param occurences [Array<Reek::AST::Node>] the occurences of the ControlParameter smell
        #   e.g. [s(:lvar, :bravo), s(:lvar, :bravo)]
        #
        def initialize(parameter, occurences)
          @parameter = parameter
          @occurences = occurences
        end

        def smells?
          occurences.any?
        end

        def lines
          occurences.map(&:line)
        end

        def name
          parameter.to_s
        end

        private

        attr_reader :occurences, :parameter
      end
    end
  end
end
