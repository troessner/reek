$:.unshift File.dirname(__FILE__)

require 'reek/options'

module Reek
  module Smells

    class Smell
      include Comparable

      def self.convert_camel_case(class_name)
        class_name.gsub(/([a-z])([A-Z])/) { |sub| "#{$1} #{$2}"}
      end

      def initialize(context, arg=nil)
        @context = context
      end

      def hash  # :nodoc:
        report.hash
      end

      def <=>(other)  # :nodoc:
        Options[:sort_order].compare(self, other)
      end

      alias eql? <=>

      def name
        Smell.convert_camel_case(self.class.name.split(/::/)[2])
      end

      def report
        "[#{name}] #{detailed_report}"
      end

      alias inspect report
    end

  end
end
