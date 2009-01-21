$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'

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

      def self.contexts      # :nodoc:
        [:class]
      end

      def initialize(config = {})
        super
        @max_methods = config.fetch('max_methods', 25)
        @exceptions += ['Hash', 'Module']
      end

      #
      # Checks the length of the given +klass+.
      # Any smells found are added to the +report+.
      #
      def examine_context(klass, report)
        num_methods = klass.num_methods
        return false if num_methods <= @max_methods
        report << SmellWarning.new(smell_name, klass,
                    "has at least #{num_methods} methods")
      end
    end
  end
end
