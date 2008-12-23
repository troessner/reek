$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

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
    class UncommunicativeName < Smell
      
      @@bad_name_patterns = [/^.[0-9]*$/]

      #
      # Checks the given +method+ for uncommunicative method name,
      # parameter names, local variable names and instance variable names.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine_context(context, report)
        consider_name(context, report) unless exception?(context.to_s)
        consider_variables(context, report)
      end
      
      def self.consider_variables(context, report)
        result = false
        context.variable_names.each do |name|
          next unless is_bad_name?(name)
          result = (report << new(name.to_s, context, 'variable'))
        end
        result
      end

      def self.consider_name(context, report)  # :nodoc:
        name = context.name
        return false unless is_bad_name?(name)
        report << new(name.to_s, context, '')
      end

      def self.is_bad_name?(name)
        name = name.effective_name
        return false if name == '*'
        @@bad_name_patterns.detect {|patt| patt === name}
      end

      def self.set_default_values(hash)      # :nodoc:
        @@bad_name_patterns = hash['bad_names']
      end

      def self.contexts      # :nodoc:
        [:class, :defn, :defs, :iter]
      end

      def initialize(name, context, symbol_type)
        super(context, symbol_type)
        @bad_name = name
        @symbol_type = symbol_type
      end

      def detailed_report
        "#{@context.to_s} has the #{@symbol_type} name '#{@bad_name}'"
      end
    end

  end
end
