require_relative 'smell_detector'

module Reek
  module Smells
    # Checking for nil is a special kind of type check, and therefore a case of
    # SimulatedPolymorphism.
    #
    # See docs/Nil-Check for details.
    class NilCheck < SmellDetector
      def self.smell_category
        'SimulatedPolymorphism'
      end

      def examine_context(ctx)
        call_node_finder = NodeFinder.new(ctx, :send, NilCallNodeDetector)
        case_node_finder = NodeFinder.new(ctx, :when, NilWhenNodeDetector)
        smelly_nodes = call_node_finder.smelly_nodes + case_node_finder.smelly_nodes

        smelly_nodes.map do |node|
          SmellWarning.new self,
                           context: ctx.full_name,
                           lines: [node.line],
                           message: 'performs a nil-check'
        end
      end

      #
      # A base class that allows to work on all nodes of a certain type.
      #
      class NodeFinder
        def initialize(ctx, type, detector = nil)
          @nodes = ctx.local_nodes(type)
          @detector = detector
        end

        def smelly_nodes
          @nodes.select do |when_node|
            @detector.detect(when_node)
          end
        end
      end

      # Detect 'call' nodes which perform a nil check.
      module NilCallNodeDetector
        module_function

        def detect(node)
          nil_query?(node) || nil_comparison?(node)
        end

        def nil_query?(call)
          call.method_name == :nil?
        end

        def nil_comparison?(call)
          comparison_call?(call) && involves_nil?(call)
        end

        def comparison_call?(call)
          comparison_methods.include? call.method_name
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
    end
  end
end
