# frozen_string_literal: true

require_relative './condition_finder'

module Reek
  module SmellDetectors
    module ControlParameterHelpers
      #
      # CallInConditionFinder finds usages of the given parameter
      # in the context of a method call in a condition, e.g.:
      #
      # def alfa(bravo)
      #   if charlie(bravo)
      #     delta
      #   end
      # end
      #
      # or
      #
      # def alfa(bravo)
      #   if bravo.charlie?
      #     delta
      #   end
      # end
      #
      # Those usages are legit and should not trigger the ControlParameter smell warning.
      #
      class CallInConditionFinder
        include ConditionFinder
        COMPARISON_METHOD_NAMES = [:==, :!=, :=~].freeze

        #
        # @param node [Reek::AST::Node] the node in our current scope,
        #   e.g. s(:def, :alfa,
        #          s(:args,
        #            s(:arg, :bravo),
        # @param parameter [Symbol]
        #   e.g. in the example above this would be :bravo
        #
        def initialize(node, parameter)
          @node = node
          @parameter = parameter
        end

        #
        # @return [Boolean] if the parameter in question has been used in the context of a method call in a condition
        #
        def uses_param_in_call_in_condition?
          return false unless condition
          condition.each_node(:send) do |inner|
            return true if regular_call_involving_param?(inner)
          end
          false
        end

        private

        attr_reader :node, :parameter

        #
        # @return [Boolean] if the parameter in question is used in a method call that is not a comparison call
        #   e.g. this would return true given that "bravo" is the parameter in question:
        #
        #     if charlie(bravo) then delta end
        #
        #   while this would return false (since its a comparison):
        #
        #     if bravo == charlie then charlie end
        #
        def regular_call_involving_param?(call_node)
          call_involving_param?(call_node) && !comparison_call?(call_node)
        end

        def call_involving_param?(call_node)
          call_node.each_node(:lvar).any? { |it| it.var_name == parameter }
        end

        # :reek:UtilityFunction
        def comparison_call?(call_node)
          COMPARISON_METHOD_NAMES.include? call_node.name
        end
      end
    end
  end
end
