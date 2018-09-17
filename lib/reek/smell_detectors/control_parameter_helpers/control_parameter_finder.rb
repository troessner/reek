# frozen_string_literal: true

require_relative './call_in_condition_finder'
require_relative '../../ast/node'

module Reek
  module SmellDetectors
    module ControlParameterHelpers
      # Finds cases of ControlParameter in a particular node for a particular parameter
      class ControlParameterFinder
        CONDITIONAL_NODE_TYPES = [:if, :case, :and, :or].freeze
        #
        # @param node [Reek::AST::Node] the node in our current scope,
        #   e.g. s(:def, :alfa,
        #          s(:args,
        #            s(:arg, :bravo),
        # @param parameter [Symbol] the parameter name in question
        #   e.g. in the example above this would be :bravo
        #
        def initialize(node, parameter)
          @node = node
          @parameter = parameter
        end

        #
        # @return [Array<Reek::AST::Node>] all nodes where the parameter is used for control flow
        #
        def find_matches
          return [] if legitimate_uses?

          nested_finders.flat_map(&:find_matches) + uses_of_param_in_condition
        end

        #
        # @return [Boolean] true if the parameter is not used for control flow
        #
        def legitimate_uses?
          return true if CallInConditionFinder.new(node, parameter).uses_param_in_call_in_condition?
          return true if parameter_used_in_body?
          return true if nested_finders.any?(&:legitimate_uses?)

          false
        end

        private

        attr_reader :node, :parameter

        #
        # @return [Boolean] if the parameter is used in the body of the method
        #   e.g. this
        #
        #   def alfa(bravo)
        #     puts bravo
        #     if bravo then charlie end
        #   end
        #
        #   would cause this method to return true because of the "puts bravo"
        #
        def parameter_used_in_body?
          nodes = node.body_nodes([:lvar], CONDITIONAL_NODE_TYPES)
          nodes.any? { |lvar_node| lvar_node.var_name == parameter }
        end

        #
        # @return [Array<ControlParameterFinder>]
        #
        def nested_finders
          @nested_finders ||= conditional_nodes.flat_map do |node|
            self.class.new(node, parameter)
          end
        end

        #
        # @return [Array<Reek::AST::Node>] all nodes where the parameter is part of a condition,
        #   e.g. [s(:lvar, :charlie)]
        #
        def uses_of_param_in_condition
          condition = node.condition
          return [] unless condition

          condition.each_node(:lvar).select { |inner| inner.var_name == parameter }
        end

        #
        # @return [Array<Reek::AST::Node>] the conditional nodes scoped below the current node
        #
        def conditional_nodes
          node.body_nodes(CONDITIONAL_NODE_TYPES)
        end
      end
    end
  end
end
