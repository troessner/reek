require 'reek/smells/smell_detector'
require 'reek/smell_warning'

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
    class ControlParameter < SmellDetector

      SMELL_CLASS = 'ControlCouple'
      SMELL_SUBCLASS = self.name.split(/::/)[-1]
      PARAMETER_KEY = 'parameter'
      VALUE_POSITION = 1

      #
      # Checks whether the given method chooses its execution path
      # by testing the value of one of its parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        control_parameters(ctx).map do |lvars, occurs|
          param = lvars.format_ruby
          lines = occurs.map {|exp| exp.line}
          smell = SmellWarning.new(SMELL_CLASS, ctx.full_name, lines,
                                   "is controlled by argument #{param}",
                                   @source, SMELL_SUBCLASS,
                                   {PARAMETER_KEY => param})
          smell
        end
      end

      private

      def control_parameters(method_ctx)
        result = Hash.new {|hash, key| hash[key] = []}
        method_ctx.exp.parameter_names.each do |param|
          next if used_outside_conditional?(method_ctx, param)
          find_matchs(method_ctx, param).each {|match| result[match].push(match)}
        end
        result
      end

      # Returns wether the parameter is used outside of the conditional statement.
      def used_outside_conditional?(method_ctx, param)
        method_ctx.exp.each_node(:lvar, [:if, :case, :and, :or, :args]) do |node|
          return true if node.value == param
        end
        false
      end

      # Find the use of the param that match the definition of a control parameter.
      def find_matchs(method_ctx, param)
        matchs = []
        [:if, :case, :and, :or].each do |keyword|
          method_ctx.local_nodes(keyword).each do |node|
            return [] if used_besides_in_condition?(node, param)
            node.each_node(:lvar, []) {|inner| matchs.push(inner) if inner.value == param}
          end
        end
        matchs
      end

      # Returns wether the parameter is used somewhere besides in the condition of the
      # conditional statement.
      def used_besides_in_condition?(node, param)
        times_in_conditional, times_total = 0, 0
        node.each_node(:lvar, [:if, :case]) {|inner| times_total +=1 if inner[VALUE_POSITION] == param}
        if node.condition
          times_in_conditional += 1 if node.condition[VALUE_POSITION] == param
          node.condition.each do |inner|
            times_in_conditional += 1 if inner.class == Sexp && inner[VALUE_POSITION] == param
          end
        end
        return times_total > times_in_conditional
      end
    end
  end
end
