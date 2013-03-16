require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    #
    # Methods should use their parameters.
    #
    class UnusedParameters < SmellDetector

      SMELL_CLASS = 'UnusedCode'
      SMELL_SUBCLASS = name.split(/::/)[-1]

      PARAMETER_KEY = 'parameter'

      #
      # Checks whether the given method has any unused parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(method_ctx)
        return [] if method_ctx.uses_super_with_implicit_arguments?
        method_ctx.unused_params.map do |param|
          smell_warning(method_ctx, param)
        end
      end

      private

      def smell_warning(method_ctx, param)
        param_name = param.name.to_s
        SmellWarning.new(
          SMELL_CLASS,
          method_ctx.full_name,
          [ method_ctx.exp.line ],
          "has unused parameter '#{param_name}'",
          @source,
          SMELL_SUBCLASS,
          { PARAMETER_KEY => param_name }
        )
      end

    end
  end
end
