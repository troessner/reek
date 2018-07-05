# frozen_string_literal: true

require_relative './call_in_condition_finder'

module Reek
  module SmellDetectors
    module ControlParameterHelpers
      # Finds cases of ControlParameter in a particular node for a particular parameter
      class ControlParameterFinder
        # TODO: Duplicated in CallInConditionFinder
        CONDITIONAL_NODE_TYPES = [:if, :case, :and, :or].freeze

        def initialize(node, parameter)
          @node = node
          @parameter = parameter
        end

        # TODO: Docs
        def find_matches
          return [] if legitimate_uses?
          nested_finders.flat_map(&:find_matches) + uses_of_param_in_condition
        end

        # TODO: Docs
        def legitimate_uses?
          return true if parameter_used_in_body?
          return true if CallInConditionFinder.new(node, parameter).uses_param_in_call_in_condition?
          return true if nested_finders.any?(&:legitimate_uses?)
          false
        end

        private

        attr_reader :node, :parameter

        # TODO: Docs
        def parameter_used_in_body?
          nodes = node.body_nodes([:lvar], CONDITIONAL_NODE_TYPES)
          nodes.any? { |lvar_node| lvar_node.var_name == parameter }
        end

        # TODO: Docs
        def conditional_nodes
          node.body_nodes(CONDITIONAL_NODE_TYPES)
        end

        # TODO: Docs
        def nested_finders
          @nested_finders ||= conditional_nodes.flat_map do |node|
            self.class.new(node, parameter)
          end
        end

        # TODO: Duplicated in CallInConditionFinder
        def condition
          return unless CONDITIONAL_NODE_TYPES.include?(node.type)
          node.condition
        end

        # TODO: Docs
        def uses_of_param_in_condition
          return [] unless condition
          condition.each_node(:lvar).select { |inner| inner.var_name == parameter }
        end
      end
    end
  end
end
