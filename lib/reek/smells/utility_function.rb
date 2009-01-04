$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'

module Reek
  module Smells

    # 
    # A Utility Function is any instance method that has no
    # dependency on the state of the instance.
    #
    class UtilityFunction < SmellDetector

      #
      # Checks whether the given +method+ is a utility function.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def examine_context(method, report)
        return false if method.constructor? or
          method.calls.keys.length == 0 or
          method.num_statements == 0 or
          method.depends_on_instance?
        report << UtilityFunctionReport.new(method)
      end
    end

    class UtilityFunctionReport < SmellReport

      def warning
        "doesn't depend on instance state"
      end
    end
  end
end
