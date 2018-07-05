# frozen_string_literal: true

module Reek
  module SmellDetectors
    module ControlParameterHelpers
      # TODO: Docs
      class CallInConditionFinder
        CONDITIONAL_NODE_TYPES = [:if, :case, :and, :or].freeze

        def initialize(node, parameter)
          @node = node
          @parameter = parameter
        end

        # TODO: Docs
        def uses_param_in_call_in_condition?
          return unless condition
          condition.each_node(:send) do |inner|
            next unless regular_call_involving_param? inner
            return true
          end
          false
        end

        private

        attr_reader :node, :parameter

        # TODO: Docs
        def condition
          return unless CONDITIONAL_NODE_TYPES.include?(node.type)
          node.condition
        end

        # TODO: Docs
        def regular_call_involving_param?(call_node)
          call_involving_param?(call_node) && !comparison_call?(call_node)
        end

        # TODO: Docs
        def call_involving_param?(call_node)
          call_node.each_node(:lvar).any? { |it| it.var_name == parameter }
        end

        # TODO: Docs
        def comparison_call?(call_node)
          comparison_method_names.include? call_node.name
        end

        # TODO: should be a constant
        def comparison_method_names
          [:==, :!=, :=~]
        end
      end
    end
  end
end
