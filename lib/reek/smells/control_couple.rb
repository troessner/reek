$:.unshift File.dirname(__FILE__)

require 'reek/smells/smells'

module Reek
  module Smells

    #
    # Control Coupling occurs when a method or block checks the value of
    # a parameter in order to decide which execution path to take. The
    # offending parameter is often called a Control Couple.
    # 
    # Control Coupling is a kind of duplication, because the calling method
    # already knows which path should be taken.
    # 
    # Control Coupling reduces the code's flexibility by creating a
    # dependency between the caller and callee:
    # any change to the possible values of the controlling parameter must
    # be reflected on both sides of the call.
    # 
    # A Control Couple also reveals a loss of simplicity: the called
    # method probably has more than one responsibility,
    # because it includes at least two different code paths.
    #
    class ControlCouple < Smell
      def initialize(context, args)
        super
        @args = args
      end

      def recognise?(cond)
        @couple = cond
        cond[0] == :lvar and @args.include?(@couple[1])
      end

      def detailed_report
        "#{@context} is controlled by argument #{Printer.print(@couple)}"
      end
    end

  end
end
