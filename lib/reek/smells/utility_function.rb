require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    # 
    # A Utility Function is any instance method that has no
    # dependency on the state of the instance.
    # 
    # Currently +UtilityFunction+ will warn about any method that:
    # 
    # * is non-empty
    # * does not override an inherited method
    # * calls at least one method on another object
    # * doesn't use any of self's instance variables
    # * doesn't use any of self's methods
    #
    class UtilityFunction < SmellDetector

      #
      # Checks whether the given +method+ is a utility function.
      # Any smells found are added to the +report+.
      #
      def examine_context(method, report)
        return false if method.calls.keys.length == 0 or
          method.num_statements == 0 or
          method.depends_on_instance?
        report << SmellWarning.new(self, method,
                      "doesn't depend on instance state")
      end
    end
  end
end
