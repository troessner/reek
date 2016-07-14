# frozen_string_literal: true
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # The +InstanceVariableAssumption+ class is responsible for
    # detecting directly access of instance variables in a class
    # that does not define them in its initialize method.
    #
    class InstanceVariableAssumption < SmellDetector
      def self.contexts
        [:class]
      end

      # Checks +klass+ for instance
      # variables assumptions.
      #
      # @return [Array<SmellWarning>]
      #
      def inspect(ctx)
        method_expressions = ctx.node_instance_methods
        assumptions = InstanceVariableAssumptionsExtractor.new(method_expressions).extract

        return [] if assumptions.empty?

        build_smell_warning(ctx, assumptions)
      end

      private

      def build_smell_warning(ctx, assumptions)
        message = "assumes too much for instance variable #{assumptions.join(', ')}"

        [smell_warning(
          context: ctx,
          lines: [ctx.exp.line],
          message: message,
          parameters: { assumptions: assumptions })]
      end

      #
      # The InstanceVariableAssumptionsExtractor is the class responsible for
      # extracting the assumptions from a method expression
      #
      class InstanceVariableAssumptionsExtractor
        def initialize(method_expressions)
          @method_expressions = method_expressions
        end

        def extract
          (variables_from_context - variables_from_initialize).uniq
        end

        private

        def assumption_nodes
          [:ivasgn, :ivar]
        end

        def ignored_nodes
          [:or_asgn]
        end

        def variables_from_context
          @method_expressions.map do |mexp|
            mexp.find_nodes(assumption_nodes, ignored_nodes).map(&:name)
          end.flatten
        end

        def variables_from_initialize
          initialize_exp = @method_expressions.detect do |method_exp|
            method_exp.name == :initialize
          end

          return [] unless initialize_exp

          initialize_exp.each_node(:ivasgn).map(&:name)
        end
      end
    end
  end
end
