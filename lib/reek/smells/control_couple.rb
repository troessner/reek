require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

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
    # One possible solution is to use the Strategy Pattern
    # to pass into the callee what must be done.  This is
    # not considered to be control coupling because the
    # callee will do the same thing with the strategy,
    # whatever it happens to be.  Sometimes in Ruby the
    # strategy may actually just be a block passed in, and
    # that remains next to where the caller invokes it in
    # the source code.
    #
    class ControlCouple < SmellDetector

      #
      # Checks whether the given method chooses its execution path
      # by testing the value of one of its parameters.
      # Remembers any smells found.
      #
      def examine_context(method_ctx)
        control_parameters(method_ctx).each do |cond, occurs|
          param = cond.format
          lines = occurs.map {|exp| exp.line}
          found(method_ctx, "is controlled by argument #{param}",
            'ControlParameter', {'parameter' => param}, lines)
        end
      end

    private

      def control_parameters(method_ctx)
        params = method_ctx.exp.parameter_names
        result = Hash.new {|hash,key| hash[key] = []}
        return result if params.empty?
        method_ctx.local_nodes(:if) do |if_node|
          cond = if_node[1]
          if cond[0] == :lvar and params.include?(cond[1])
            result[cond].push(cond)
          end
        end
        result
      end
    end
  end
end
