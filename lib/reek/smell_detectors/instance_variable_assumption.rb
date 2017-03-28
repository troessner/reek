# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # The +InstanceVariableAssumption+ class is responsible for
    # detecting directly access of instance variables in a class
    # that does not define them in its initialize method.
    #
    class InstanceVariableAssumption < BaseDetector
      def self.contexts
        [:class]
      end

      # Checks +klass+ for instance
      # variables assumptions.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(ctx)
        method_expressions = ctx.node_instance_methods

        assumptions = (variables_from_context(method_expressions) -
          variables_from_initialize(method_expressions)).uniq

        assumptions.map do |assumption|
          build_smell_warning(ctx, assumption)
        end
      end

      private

      def build_smell_warning(ctx, assumption)
        message = "assumes too much for instance variable '#{assumption}'"

        smell_warning(
          context: ctx,
          lines: [ctx.exp.line],
          message: message,
          parameters: { assumption: assumption.to_s })
      end

      # :reek:UtilityFunction
      def variables_from_initialize(instance_methods)
        initialize_exp = instance_methods.detect do |method|
          method.name == :initialize
        end

        return [] unless initialize_exp

        initialize_exp.each_node(:ivasgn).map(&:name)
      end

      def variables_from_context(instance_methods)
        instance_methods.map do |method|
          method.find_nodes(assumption_nodes, ignored_nodes).map(&:name)
        end.flatten
      end

      def assumption_nodes
        [:ivar]
      end

      def ignored_nodes
        [:or_asgn]
      end
    end
  end
end
