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

      @@max_methods = 25

      #
      # Checks the length of the given +klass+.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine_context(klass, report)
        return false if exception?(klass.name.to_s)
        num_methods = klass.num_methods
        return false if num_methods <= @@max_methods
        report << new(klass, num_methods)
      end

      def self.set_default_values(hash)      # :nodoc:
        update(:max_methods, hash)
      end

      def self.contexts      # :nodoc:
        [:class]
      end
      
      def initialize(context, num_methods)
        super(context)
        @num_methods = num_methods
      end

      def detailed_report
        "#{@context.to_s} has at least #{@num_methods} methods"
      end
    end

  end
end
