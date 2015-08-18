require_relative 'smell_detector'
require_relative 'smell_warning'

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
    # See {file:docs/Control-Parameter.md} for details.
    # @api private
    class ControlParameter < SmellDetector
      def self.smell_category
        'ControlCouple'
      end

      #
      # Checks whether the given method chooses its execution path
      # by testing the value of one of its parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        ControlParameterCollector.new(ctx).control_parameters.map do |control_parameter|
          SmellWarning.new self,
                           context: ctx.full_name,
                           lines: control_parameter.lines,
                           message: "is controlled by argument #{control_parameter.name}",
                           parameters: { name: control_parameter.name.to_s }
        end
      end

      #
      # Collects information about a single control parameter.
      #
      class FoundControlParameter
        def initialize(param, occurences)
          @param = param
          @occurences = occurences
        end

        def smells?
          occurences.any?
        end

        def lines
          occurences.map(&:line)
        end

        def name
          param.to_s
        end

        private

        private_attr_reader :occurences, :param
      end

      # Finds cases of ControlParameter in a particular node for a particular parameter
      class ControlParameterFinder
        CONDITIONAL_NODE_TYPES = [:if, :case, :and, :or]

        def initialize(node, param)
          @node = node
          @param = param
        end

        def find_matches
          return [] if legitimite_uses?
          nested_finders.flat_map(&:find_matches) + uses_of_param_in_condition
        end

        def legitimite_uses?
          return true if uses_param_in_body?
          return true if uses_param_in_call_in_condition?
          return true if nested_finders.any?(&:legitimite_uses?)
          false
        end

        private

        private_attr_reader :node, :param

        def conditional_nodes
          node.body_nodes(CONDITIONAL_NODE_TYPES)
        end

        def nested_finders
          @nested_finders ||= conditional_nodes.flat_map do |node|
            self.class.new(node, param)
          end
        end

        def uses_param_in_call_in_condition?
          return unless condition
          condition.each_node(:send) do |inner|
            next unless regular_call_involving_param? inner
            return true
          end
          false
        end

        def uses_of_param_in_condition
          return [] unless condition
          condition.each_node(:lvar).select { |inner| inner.var_name == param }
        end

        def condition
          return nil unless CONDITIONAL_NODE_TYPES.include? node.type
          node.condition
        end

        def regular_call_involving_param?(call_node)
          call_involving_param?(call_node) && !comparison_call?(call_node)
        end

        def comparison_call?(call_node)
          comparison_method_names.include? call_node.method_name
        end

        def comparison_method_names
          [:==, :!=, :=~]
        end

        def call_involving_param?(call_node)
          call_node.each_node(:lvar).any? { |it| it.var_name == param }
        end

        def uses_param_in_body?
          nodes = node.body_nodes([:lvar], [:if, :case, :and, :or])
          nodes.any? { |lvar_node| lvar_node.var_name == param }
        end
      end

      #
      # Collects all control parameters in a given context.
      #
      class ControlParameterCollector
        def initialize(context)
          @context = context
        end

        def control_parameters
          potential_parameters.
            map { |param| FoundControlParameter.new(param, find_matches(param)) }.
            select(&:smells?)
        end

        private

        private_attr_reader :context

        def potential_parameters
          context.exp.parameter_names
        end

        def find_matches(param)
          ControlParameterFinder.new(context.exp, param).find_matches
        end
      end
    end
  end
end
