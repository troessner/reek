require 'reek/smells/smell_detector'
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
        [:defn, :defs]
      end

      #
      # Checks whether the given conditional statement relies on a control couple.
      # Remembers any smells found.
      #
      def examine_context(ctx)
        control_parameters(ctx).each do |cond, occurs|
          param = SexpFormatter.format(cond)
          lines = occurs.map {|exp| exp.line}
          found(ctx, "is controlled by argument #{param}",
            'ControlParameter', {'parameter' => param}, lines)
        end
      end

      def control_parameters(ctx)
        result = Hash.new {|hash,key| hash[key] = []}
        ctx.local_nodes(:if) do |if_node|
          cond = if_node[1]
          if cond[0] == :lvar and ctx.has_parameter(cond[1])
            result[cond].push(cond)
          end
        end
        result
      end
    end
  end
end
