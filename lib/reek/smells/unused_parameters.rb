require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # Methods should use their parameters.
    #
    # See {file:docs/Unused-Parameters.md} for details.
    class UnusedParameters < SmellDetector
      def self.smell_category
        'UnusedCode'
      end

      #
      # Checks whether the given method has any unused parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        return [] if ctx.uses_super_with_implicit_arguments?
        ctx.unused_params.map do |param|
          smell_warning(
            context: ctx,
            lines: [ctx.exp.line],
            message: "has unused parameter '#{param.name}'",
            parameters: { name: param.name.to_s })
        end
      end
    end
  end
end
