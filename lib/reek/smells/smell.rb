$:.unshift File.dirname(__FILE__)

require 'reek/options'

module Reek
  module Smells

    class Smell
      include Comparable
      
      def self.class_name
        self.name.split(/::/)[-1]
      end

      def self.configure(hash)              # :nodoc:
        section = hash[class_name]
        section['enabled'] = true
        set_default_values(section)
      end

      def self.set_default_values(hash)      # :nodoc:
      end

      def self.attach_to(hash)      # :nodoc:
        contexts.each { |ctx| hash[ctx] << self }
      end

      def self.contexts      # :nodoc:
        [:defn, :defs]
      end

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
        Smell.convert_camel_case(self.class.class_name)
      end

      def report
        "[#{name}] #{detailed_report}"
      end

      alias inspect report
    end

  end
end
