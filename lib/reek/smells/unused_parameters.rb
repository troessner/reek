require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

module Reek
  module Smells

    #
    # Methods should use their parameters.
    #
    class UnusedParameters < SmellDetector

      SMELL_CLASS = 'ControlCouple'
      SMELL_SUBCLASS = name.split(/::/)[-1]

      PARAMETER_KEY = 'parameter'

      #
      # Checks whether the given method has any unused parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(method_ctx)
        unused_params(method_ctx).map do |param|
          SmellWarning.new(SMELL_CLASS, method_ctx.full_name, [method_ctx.exp.line],
                           "has unused parameter '#{param.to_s}'",
                           @source, SMELL_SUBCLASS, {PARAMETER_KEY => param.to_s})
        end
      end

      private

      def unused_params(method_ctx)
        params(method_ctx).select do |param|
          param = sanitized_param(param)
          next if marked_unused?(param)
          unused?(method_ctx, param)
        end
      end

      def marked_unused?(param)
        param == '' || param.start_with?('_')
      end

      def unused?(method_ctx, param)
        !method_ctx.local_nodes(:lvar).include?(Sexp.new(:lvar, param.to_sym))
      end

      def params(method_ctx)
        method_ctx.exp.arg_names || []
      end

      def sanitized_param(param)
        param.to_s.sub(/^\*/, '')
      end

    end
  end
end
