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
        params = method_ctx.exp.arg_names || []
        params.select do |param|
          param = param.to_s.sub(/^\*/, '')
          !["", "_"].include?(param) &&
            !method_ctx.local_nodes(:lvar).include?(Sexp.new(:lvar, param.to_sym))
        end.map do |param|
          SmellWarning.new(SMELL_CLASS, method_ctx.full_name, [method_ctx.exp.line],
                           "has unused parameter '#{param.to_s}'",
                           @source, SMELL_SUBCLASS, {PARAMETER_KEY => param.to_s})
        end
      end

    end
  end
end
