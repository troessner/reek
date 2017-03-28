# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    # Checking for nil is a special kind of type check, and therefore a case of
    # SimulatedPolymorphism.
    #
    # See {file:docs/Nil-Check.md} for details.
    class NilCheck < BaseDetector
      def sniff(ctx)
        lines = NodeDetector.new(ctx).detect.map(&:line)
        if lines.any?
          [smell_warning(
            context: ctx,
            lines: lines,
            message: 'performs a nil-check')]
        else
          []
        end
      end

      # Detect all nodes that smell of NilCheck
      class NodeDetector
        attr_reader :ctx
        def initialize(ctx)
          @ctx = ctx
        end

        def detect
          finders = [NodeFinder.new(ctx, :send, NilCallNodeDetector),
                     NodeFinder.new(ctx, :when, NilWhenNodeDetector),
                     NodeFinder.new(ctx, :csend, SafeNavigationNodeDetector)]
          finders.flat_map(&:smelly_nodes)
        end
      end

      #
      # A base class that allows to work on all nodes of a certain type.
      #
      class NodeFinder
        def initialize(ctx, type, detector)
          @nodes = ctx.local_nodes(type)
          @detector = detector
        end

        def smelly_nodes
          nodes.select do |when_node|
            detector.detect(when_node)
          end
        end

        private

        attr_reader :detector, :nodes
      end

      private_constant :NodeFinder

      # Detect 'call' nodes which perform a nil check.
      module NilCallNodeDetector
        module_function

        def detect(node)
          nil_query?(node) || nil_comparison?(node)
        end

        def nil_query?(call)
          call.name == :nil?
        end

        def nil_comparison?(call)
          comparison_call?(call) && involves_nil?(call)
        end

        def comparison_call?(call)
          comparison_methods.include? call.name
        end

        def involves_nil?(call)
          call.participants.any? { |it| it.type == :nil }
        end

        def comparison_methods
          [:==, :===]
        end
      end

      # Detect 'when' statements that perform a nil check.
      module NilWhenNodeDetector
        module_function

        def detect(node)
          node.condition_list.any? { |it| it.type == :nil }
        end
      end

      # Detect safe navigation. Returns true for all nodes, since all :csend
      # nodes are considered smelly.
      module SafeNavigationNodeDetector
        module_function

        def detect(_node)
          true
        end
      end
    end
  end
end
