require 'reek/smells/smell_detector'
require 'reek/smell_warning'
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

      # The name of the config field that sets the maximum number of
      # identical calls to be permitted within any single method.
      MAX_ALLOWED_CALLS_KEY = 'max_calls'

      DEFAULT_MAX_CALLS = 1

      def self.default_config
        super.adopt(MAX_ALLOWED_CALLS_KEY => DEFAULT_MAX_CALLS)
      end

      def initialize(config = Duplication.default_config)
        super(config)
      end

      def examine_context(method)
        smelly_calls(method).each do |call_data|
          num = call_data[1]
          multiple = num == 2 ? 'twice' : "#{num} times"
          found(method, "calls #{SexpFormatter.format(call_data[0])} #{multiple}")
        end
      end
      
      def smelly_calls(method)   # :nodoc:
        method.calls.select do |key,val|
          val > value(MAX_ALLOWED_CALLS_KEY, method, DEFAULT_MAX_CALLS) and key[2] != :new
        end
      end
    end
  end
end
