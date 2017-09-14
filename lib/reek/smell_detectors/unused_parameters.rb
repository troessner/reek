# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # Methods should use their parameters.
    #
    # See {file:docs/Unused-Parameters.md} for details.
    class UnusedParameters < BaseDetector
      #
      # Checks whether the given method has any unused parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        return [] if context.uses_super_with_implicit_arguments?
        context.unused_params.map do |param|
          name = param.name.to_s
          smell_warning(
            context: context,
            lines: [source_line],
            message: "has unused parameter '#{name}'",
            parameters: { name: name })
        end
      end
    end
  end
end
