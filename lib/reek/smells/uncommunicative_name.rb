$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # An Uncommunicative Name is a name that doesn't communicate its intent
    # well enough.
    # 
    # Poor names make it hard for the reader to build a mental picture
    # of what's going on in the code. They can also be mis-interpreted;
    # and they hurt the flow of reading, because the reader must slow
    # down to interpret the names.
    #
    # Currently +UncommunicativeName+ checks for
    # * 1-character names
    # * names consisting of a single character followed by a number
    #
    class UncommunicativeName < SmellDetector

      def self.contexts      # :nodoc:
        [:class, :defn, :defs, :iter]
      end

      def initialize(config = {})
        super
        @bad_names = config.fetch('bad_names', [/^.[0-9]*$/])
      end

      #
      # Checks the given +method+ for uncommunicative method name,
      # parameter names, local variable names and instance variable names.
      # Any smells found are added to the +report+.
      #
      def examine_context(context, report)
        consider_name(context, report) unless exception?(context.to_s)
        consider_variables(context, report)
      end
      
      def consider_variables(context, report)
        context.variable_names.each do |name|
          next unless is_bad_name?(name)
          report << SmellWarning.new(smell_name, context,
                      "has the variable name '#{name}'")
        end
      end

      def consider_name(context, report)  # :nodoc:
        name = context.name
        return false unless is_bad_name?(name)
        report << SmellWarning.new(smell_name, context,
                      "has the name '#{name}'")
      end

      def is_bad_name?(name)
        name = name.effective_name
        return false if name == '*'
        @bad_names.detect {|patt| patt === name}
      end
    end
  end
end
