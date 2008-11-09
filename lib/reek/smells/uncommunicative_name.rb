$:.unshift File.dirname(__FILE__)

require 'reek/smells/smells'

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
    # Currently +UncommunicativeName+ checks for 1-character names, and
    # names consisting of a single character followed by a number.
    #
    class UncommunicativeName < Smell

      def self.examine(method, report)
        consider(method.name, method, report, 'method')
        method.parameters.each do |param|
          consider(param, method, report, 'parameter')
        end
        method.local_variables.each do |lvar|
          consider(lvar, method, report, 'local variable')
        end
        method.instance_variables.each do |ivar|
          consider(ivar, method, report, 'field')
        end
      end

      def self.consider(sym, method, report, type)
        name = sym.to_s
        report << new(name, method, type) if is_bad_name?(name)
      end

      def self.is_bad_name?(name)
        return false if name == '*'
        name = name[1..-1] while /^@/ === name
        return true if name.length < 2
        return true if /^.[0-9]$/ === name
        false
      end

      def initialize(name, context, symbol_type)
        super(context, symbol_type)
        @bad_name = name
        @symbol_type = symbol_type
      end

      def recognise?(symbol)
        @symbol = symbol.to_s
        UncommunicativeName.effective_length(@symbol) < 2
      end

      def detailed_report
        "#{@context} uses the #{@symbol_type} name '#{@bad_name}'"
      end
    end

  end
end
