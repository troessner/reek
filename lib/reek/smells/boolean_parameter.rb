require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    #
    # A Boolean parameter effectively permits a method's caller
    # to decide which execution path to take. The
    # offending parameter is a kind of Control Couple.
    # 
    # Currently Reek can only detect a Boolean parameter when it has a
    # default initializer.
    #
    class BooleanParameter < SmellDetector

      SMELL_CLASS = 'ControlCouple'
      SMELL_SUBCLASS = self.name.split(/::/)[-1]

      PARAMETER_KEY = 'parameter'

      #
      # Checks whether the given method has any Boolean parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(method_ctx)
        method_ctx.parameters.default_assignments.select do |param, value|
          [:true, :false].include?(value[0])
        end.map do |param, value|
          SmellWarning.new(SMELL_CLASS, method_ctx.full_name, [method_ctx.exp.line],
                           "has boolean parameter '#{param.to_s}'",
                           @source, SMELL_SUBCLASS, {PARAMETER_KEY => param.to_s})
        end
      end
    end
  end
end
