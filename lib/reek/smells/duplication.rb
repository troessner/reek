$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'
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
    class Duplication < Smell

      MAX_CALLS_KEY = 'max_calls'      
      
      #
      # Checks the given +method+ for duplication.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine(method, report)
        smell_found = false
        smelly_calls(method).each do |call|
          report << new(method, call)
          smell_found = true
        end
        return smell_found
      end
      
      def self.smelly_calls(method)   # :nodoc:
        method.calls.select do |key,val|
          val > config[MAX_CALLS_KEY] and key[2] != :new
        end.map { |call_exp| call_exp[0] }
      end

      def self.set_default_values(hash)      # :nodoc:
        hash[MAX_CALLS_KEY] = 1
      end

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
