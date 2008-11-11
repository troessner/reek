$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods or lines of code.
    # 
    # Currently +LargeClass+ only reports classes having more than
    # +MAX_ALLOWED+ methods.
    #
    class LargeClass < Smell
      MAX_ALLOWED = 25

      def self.non_inherited_methods(klass)
        return klass.instance_methods if klass.superclass.nil?
        klass.instance_methods - klass.superclass.instance_methods
      end

      def recognise?(name)
        klass = Object.const_get(name) rescue return
        @num_methods = LargeClass.non_inherited_methods(klass).length
        @num_methods > MAX_ALLOWED
      end

      def detailed_report
        "#{@context} has #{@num_methods} methods"
      end
    end

  end
end
