require 'reek/smells/smell_detector'
require 'reek/smell_warning'
require 'reek/sexp_formatter'

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

      def self.contexts      # :nodoc:
        [:if, :defn, :defs]
      end

      #
      # Checks whether the given conditional statement relies on a control couple.
      # Remembers any smells found.
      #
      def examine_context(ctx)
        case ctx
        when IfContext
          return unless ctx.tests_a_parameter?
          found(ctx, "is controlled by argument #{SexpFormatter.format(ctx.if_expr)}")
        when MethodContext
          ctx.parameters.default_assignments.each do |param, value|
            next unless [:true, :false].include?(value[0])
            found(ctx, "is controlled by argument #{param.to_s}")
          end
        else
        end
      end
    end
  end
end
