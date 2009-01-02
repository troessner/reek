$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell_detector'

module Reek
  module Smells

    #
    # Control Coupling occurs when a method or block checks the value of
    # a parameter in order to decide which execution path to take. The
    # offending parameter is often called a Control Couple.
    # 
    # A simple example would be the <tt>quoted</tt> parameter
    # in the following method:
    # 
    #  def write(quoted)
    #    if quoted
    #      write_quoted(@value)
    #    else
    #      puts @value
    #    end
    #  end
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
    class ControlCouple < SmellDetector

      #
      # Checks whether the given conditional statement relies on a control couple.
      # Any smells found are added to the +report+; returns true in that case,
      # and false otherwise.
      #
      def self.examine_context(cond, report)
        if_expr = cond.if_expr
        return false if if_expr[0] != :lvar
        return false unless cond.has_parameter(if_expr[1])
        report << ControlCoupleReport.new(cond, if_expr)
      end

      def self.contexts      # :nodoc:
        [:if]
      end
    end

    class ControlCoupleReport < SmellDetector
      
      def initialize(context, couple)
        super(context)
        @couple = couple
      end

      def detailed_report
        "#{@context.to_s} is controlled by argument #{Printer.print(@couple)}"
      end      
    end
  end
end
