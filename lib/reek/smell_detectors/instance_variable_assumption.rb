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
      def sniff
        assumptions = (variables_from_context - variables_from_initialize).uniq

        assumptions.map do |assumption|
          build_smell_warning(assumption)
        end
      end

      private

      def method_expressions
        @method_expressions ||= context.node_instance_methods
      end

      def build_smell_warning(assumption)
        message = "assumes too much for instance variable '#{assumption}'"

        smell_warning(
          context: context,
          lines: [source_line],
          message: message,
          parameters: { assumption: assumption.to_s })
      end

      def variables_from_initialize
        initialize_exp = method_expressions.detect do |method|
          method.name == :initialize
        end

        return [] unless initialize_exp

        initialize_exp.each_node(:ivasgn).map(&:name)
      end

      def variables_from_context
        method_expressions.map do |method|
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
