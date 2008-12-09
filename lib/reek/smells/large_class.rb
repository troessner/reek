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
      MAX_ALLOWED = 25

      #
      # Checks the length of the given +klass+.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine(klass, report)
        begin
          klass_obj = Object.const_get(klass.name.to_s)
          num_methods = non_inherited_methods(klass_obj).length
        rescue
          num_methods = klass.num_methods
        end
        return false if num_methods <= MAX_ALLOWED
        report << new(klass, num_methods)
      end

      def self.non_inherited_methods(klass_obj)
        methods = klass_obj.instance_methods
        superk = klass_obj.superclass
        return methods if superk.nil?
        methods - superk.instance_methods
      end

      def self.set_default_values(hash)      # :nodoc:
        hash['max_methods'] = 25
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
