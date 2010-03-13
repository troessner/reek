require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

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

      #
      # Checks whether the given method has a Boolean parameter.
      # Remembers any smells found.
      #
      def examine_context(method_ctx)
        method_ctx.parameters.default_assignments.each do |param, value|
          next unless [:true, :false].include?(value[0])
          smell = SmellWarning.new('ControlCouple', method_ctx.full_name, [method_ctx.exp.line],
            "has boolean parameter '#{param.to_s}'",
            @source, 'BooleanParameter', {'parameter' => param.to_s})
          @smells_found << smell
          #SMELL: serious duplication
        end
      end
    end
  end
end
