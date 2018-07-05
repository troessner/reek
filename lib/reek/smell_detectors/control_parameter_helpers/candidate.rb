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
        # TODO: How can this be more than one? Why is this an array and not just a skalar?
        # @param occurences [Array<Reek::AST::Node>] TODO: description
        #   e.g. [s(:lvar, :bravo)]
        #
        def initialize(param, occurences)
          @param = param
          @occurences = occurences
        end

        #
        # @return [Boolean]
        #
        def smells?
          occurences.any?
        end

        def lines
          occurences.map(&:line)
        end

        def name
          param.to_s
        end

        private

        attr_reader :occurences, :param
      end
    end
  end
end
