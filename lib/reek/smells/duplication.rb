$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'
require 'reek/sexp_formatter'

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

      def initialize(config = {})
        super
        @max_calls = config.fetch('max_calls', 1)
      end

      def examine_context(method, report)
        smelly_calls(method).each do |call|
          report << SmellWarning.new(smell_name, method,
                      "calls #{SexpFormatter.format(call)} multiple times")
        end
      end
      
      def smelly_calls(method)   # :nodoc:
        method.calls.select do |key,val|
          val > @max_calls and key[2] != :new
        end.map { |call_exp| call_exp[0] }
      end
    end
  end
end
