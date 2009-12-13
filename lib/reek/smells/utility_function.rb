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
    # * is non-empty, and
    # * does not override an inherited method, and
    # * calls at least one method on another object, and
    # * doesn't use any of self's instance variables, and
    # * doesn't use any of self's methods
    #
    class UtilityFunction < SmellDetector

      # The name of the config field that sets the maximum number of
      # calls permitted within a helper method. Any method with more than
      # this number of method calls on other objects will be considered a
      # candidate Utility Function.
      HELPER_CALLS_LIMIT_KEY = 'max_helper_calls'

      DEFAULT_HELPER_CALLS_LIMIT = 1

      def self.default_config
        super.adopt(HELPER_CALLS_LIMIT_KEY => DEFAULT_HELPER_CALLS_LIMIT)
      end

      def initialize(source = '???', config = UtilityFunction.default_config)
        super(source, config)
      end

      #
      # Checks whether the given +method+ is a utility function.
      # Remembers any smells found.
      #
      def examine_context(method)
        return false if method.num_statements == 0 or
          method.depends_on_instance? or
          method.calls.keys.length <= value(HELPER_CALLS_LIMIT_KEY, method, DEFAULT_HELPER_CALLS_LIMIT)
          # SMELL: loads of calls to value{} with the above pattern
        found(method, "doesn't depend on instance state")
      end
    end
  end
end
