$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'
require 'reek/printer'

module Reek
  module Smells

    #
    # Duplication occurs when two fragments of code look nearly identical,
    # or when two fragments of code have nearly identical effects
    # at some conceptual level.
    # 
    # Currently +Duplication+ checks for repeated identical method calls
    # within any one method definition. For example, the following method
    # will report a warning:
    # 
    #   def double_thing()
    #     @other.thing + @other.thing
    #   end
    #
    class Duplication < SmellDetector

      @@max_calls = 1

      def self.examine_context(method, report)
        smelly_calls(method).each do |call|
          report << DuplicationReport.new(method, call)
        end
      end
      
      def self.smelly_calls(method)   # :nodoc:
        method.calls.select do |key,val|
          val > @@max_calls and key[2] != :new
        end.map { |call_exp| call_exp[0] }
      end

      def self.set_default_values(hash)      # :nodoc:
        update(:max_calls, hash)
      end
    end

    class DuplicationReport < SmellReport

      def initialize(context, call)
        super(context)
        @call = call
      end

      def detailed_report
        "#{@context.to_s} calls #{Printer.print(@call)} multiple times"
      end
    end
  end
end
