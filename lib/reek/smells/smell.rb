$:.unshift File.dirname(__FILE__)

require 'reek/options'

module Reek
  module Smells

    class Smell
      include Comparable

      def self.convert_camel_case(class_name)
        class_name.gsub(/([a-z])([A-Z])/) { |s| "#{$1} #{$2}"}
      end

      def initialize(context, arg=nil)
        @context = context
      end

      def self.check(exp, context, arg=nil)
        smell = new(context, arg)
        return false unless smell.recognise?(exp)
        context.report(smell)
        true
      end

      def recognise?(stuff)
        @context != nil
      end

      def hash  # :nodoc:
        report.hash
      end

      def <=>(other)  # :nodoc:
        Options[:sort_order].compare(self, other)
      end

      alias eql? <=>

      def name
        self.class.convert_camel_case(self.class.name.split(/::/)[2])
      end

      def report
        "[#{name}] #{detailed_report}"
      end

      alias inspect report

      def to_s
        report
      end
    end

  end
end
