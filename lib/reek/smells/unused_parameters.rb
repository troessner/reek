# frozen_string_literal: true
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # Methods should use their parameters.
    #
    # See {file:docs/Unused-Parameters.md} for details.
    class UnusedParameters < SmellDetector
      #
      # Checks whether the given method has any unused parameters.
      #
      # @return [Array<SmellWarning>]
      #
      # :reek:FeatureEnvy
      def sniff(ctx)
        return [] if ctx.uses_super_with_implicit_arguments?
        ctx.unused_params.map do |param|
          name = param.name.to_s
          smell_warning(
            context: ctx,
            lines: [ctx.exp.line],
            message: "has unused parameter '#{name}'",
            parameters: { name: name })
        end
      end
    end
  end
end
