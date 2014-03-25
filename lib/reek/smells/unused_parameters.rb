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

      EMPTY_ARRAY  = [].freeze
      EMPTY_STRING = ''.freeze
      SPLAT_MATCH  = /^\*/.freeze
      UNDERSCORE   = '_'.freeze

      #
      # Checks whether the given method has any unused parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(method_ctx)
        return EMPTY_ARRAY if zsuper?(method_ctx)
        unused_params(method_ctx).map do |param|
          smell_warning(method_ctx, param)
        end
      end

      private

      def unused_params(method_ctx)
        params(method_ctx).select do |param|
          param = sanitized_param(param)
          next if skip?(param)
          !method_ctx.uses_param?(param)
        end
      end

      def skip?(param)
        anonymous_splat?(param) || marked_unused?(param)
      end

      def params(method_ctx)
        method_ctx.exp.arg_names || EMPTY_ARRAY
      end

      def sanitized_param(param)
        param.to_s.sub(SPLAT_MATCH, EMPTY_STRING)
      end

      def marked_unused?(param)
        param.start_with?(UNDERSCORE)
      end

      def anonymous_splat?(param)
        param == EMPTY_STRING
      end

      def zsuper?(method_ctx)
        method_ctx.exp.body.has_nested_node? :zsuper
      end

      def smell_warning(method_ctx, param)
        param_name = param.to_s
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
