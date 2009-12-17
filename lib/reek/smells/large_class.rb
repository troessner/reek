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
      SUBCLASS_TOO_MANY_METHODS = 'TooManyMethods'
      SUBCLASS_TOO_MANY_IVARS = 'TooManyInstanceVariables'

      # The name of the config field that sets the maximum number of methods
      # permitted in a class.
      MAX_ALLOWED_METHODS_KEY = 'max_methods'

      DEFAULT_MAX_METHODS = 25

      # The name of the config field that sets the maximum number of instance
      # variables permitted in a class.
      MAX_ALLOWED_IVARS_KEY = 'max_instance_variables'

      DEFAULT_MAX_IVARS = 9

      def self.contexts      # :nodoc:
        [:class]
      end

      def self.default_config
        super.adopt(
          MAX_ALLOWED_METHODS_KEY => DEFAULT_MAX_METHODS,
          MAX_ALLOWED_IVARS_KEY => DEFAULT_MAX_IVARS,
          EXCLUDE_KEY => []
          )
      end

      def initialize(source = '???', config = LargeClass.default_config)
        super(source, config)
      end

      def check_num_methods(klass)  # :nodoc:
        actual = klass.local_nodes(:defn).length
        return if actual <= value(MAX_ALLOWED_METHODS_KEY, klass, DEFAULT_MAX_METHODS)
        found(klass, "has at least #{actual} methods", SUBCLASS_TOO_MANY_METHODS, {'method_count' => actual})
      end

      def check_num_ivars(klass)  # :nodoc:
        count = klass.variable_names.length
        return if count <= value(MAX_ALLOWED_IVARS_KEY, klass, DEFAULT_MAX_IVARS)
        found(klass, "has at least #{count} instance variables", SUBCLASS_TOO_MANY_IVARS, {'ivar_count' => count})
      end

      #
      # Checks +klass+ for too many methods or too many instance variables.
      # Remembers any smells found.
      #
      def examine_context(klass)
        check_num_methods(klass)
        check_num_ivars(klass)
      end
    end
  end
end
