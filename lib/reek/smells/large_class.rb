require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods or lines of code.
    # 
    # Currently +LargeClass+ only reports classes having more than a
    # configurable number of methods. This includes public, protected and
    # private methods, but excludes methods inherited from superclasses or
    # included modules.
    #
    class LargeClass < SmellDetector

      # The name of the config field that sets the maximum number of methods
      # permitted in a class.
      MAX_ALLOWED_METHODS_KEY = 'max_methods'

      def self.contexts      # :nodoc:
        [:class]
      end

      def self.default_config
        super.adopt(
          MAX_ALLOWED_METHODS_KEY => 25,
          EXCLUDE_KEY => ['Array', 'Hash', 'Module', 'String']
          )
      end

      def initialize(config = LargeClass.default_config)
        super
        @max_methods = config[MAX_ALLOWED_METHODS_KEY]
      end

      #
      # Checks the length of the given +klass+.
      # Any smells found are added to the +report+.
      #
      def examine_context(klass, report)
        num_methods = klass.num_methods
        return false if num_methods <= @max_methods
        report << SmellWarning.new(self, klass,
                    "has at least #{num_methods} methods")
      end
    end
  end
end
