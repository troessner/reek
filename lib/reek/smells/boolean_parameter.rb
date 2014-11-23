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
      def smell_class_name
        'ControlCouple'
      end

      def message_template
        "has boolean parameter '%{name}'"
      end

      #
      # Checks whether the given method has any Boolean parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(method_ctx)
        method_ctx.parameters.default_assignments.select do |_param, value|
          [:true, :false].include?(value[0])
        end.map do |parameter, _value|
          SmellWarning.new self, context: method_ctx.full_name, lines: [method_ctx.exp.line], parameters: { 'name' => parameter.to_s }
        end
      end
    end
  end
end
