# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # A Boolean parameter effectively permits a method's caller
    # to decide which execution path to take. The
    # offending parameter is a kind of Control Couple.
    #
    # Currently Reek can only detect a Boolean parameter when it has a
    # default initializer.
    #
    # See {file:docs/Boolean-Parameter.md} for details.
    class BooleanParameter < BaseDetector
      #
      # Checks whether the given method has any Boolean parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        context.default_assignments.select do |_parameter, value|
          [:true, :false].include?(value.type)
        end.map do |parameter, _value|
          smell_warning(
            context: context,
            lines: [source_line],
            message: "has boolean parameter '#{parameter}'",
            parameters: { parameter: parameter.to_s })
        end
      end
    end
  end
end
