require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods or lines of code.
    # 
    # Currently +LargeClass+ only reports classes having more than a
    # configurable number of methods or instance variables. The method count
    # includes public, protected and
    # private methods, and excludes methods inherited from superclasses or
    # included modules.
    #
    class LargeClass < SmellDetector

      # The name of the config field that sets the maximum number of methods
      # permitted in a class.
      MAX_ALLOWED_METHODS_KEY = 'max_methods'

      # The name of the config field that sets the maximum number of instance
      # variables permitted in a class.
      MAX_ALLOWED_IVARS_KEY = 'max_instance_variables'

      def self.contexts      # :nodoc:
        [:class]
      end

      def self.default_config
        super.adopt(
          MAX_ALLOWED_METHODS_KEY => 25,
          MAX_ALLOWED_IVARS_KEY => 9,
          EXCLUDE_KEY => []
          )
      end

      def initialize(config = LargeClass.default_config)
        super
        @max_methods = config[MAX_ALLOWED_METHODS_KEY]
        @max_instance_variables = config[MAX_ALLOWED_IVARS_KEY]
      end

      def check_num_methods(klass, report)  # :nodoc:
        count = klass.num_methods
        return if count <= @max_methods
        report << SmellWarning.new(self, klass,
                    "has at least #{count} methods")
      end

      def check_num_ivars(klass, report)  # :nodoc:
        count = klass.variable_names.length
        return if count <= @max_instance_variables
        report << SmellWarning.new(self, klass,
                    "has at least #{count} instance variables")
      end

      #
      # Checks +klass+ for too many methods or too many instance variables.
      # Any smells found are added to the +report+.
      #
      def examine_context(klass, report)
        check_num_methods(klass, report)
        check_num_ivars(klass, report)
      end
    end
  end
end
