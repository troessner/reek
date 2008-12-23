$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods or lines of code.
    # 
    # Currently +LargeClass+ only reports classes having more than
    # +MAX_ALLOWED+ public methods.
    #
    class LargeClass < Smell

      MAX_METHODS_KEY = 'max_methods'
      EXCEPTIONS_KEY = 'exceptions'

      #
      # Checks the length of the given +klass+.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine_context(klass, report)
        return false if config[EXCEPTIONS_KEY].include?(klass.name.to_s)
        num_methods = klass.num_methods
        return false if num_methods <= config[MAX_METHODS_KEY]
        report << new(klass, num_methods)
      end

      def self.set_default_values(hash)      # :nodoc:
        hash[MAX_METHODS_KEY] = 25
        hash[EXCEPTIONS_KEY] = ['Dir', 'Hash', 'Module']
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
