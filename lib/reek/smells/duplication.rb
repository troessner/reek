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

      #
      # Checks the given +method+ for duplication.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine(method, report)
        look_for_duplicate_calls(method, report)
      end

      def self.look_for_duplicate_calls(method, report)  # :nodoc:
        smell_found = false
        method.calls.select {|key,val| val > 1}.each do |call_exp|
          call = call_exp[0]
          unless call[2] == :new
            report << new(method, call)
            smell_found = true
          end
        end
        return smell_found
      end

      def initialize(context, call)
        super(context)
        @call = call
      end

      def detailed_report
        "#{@context} calls #{Printer.print(@call)} more than once"
      end
    end

  end
end
