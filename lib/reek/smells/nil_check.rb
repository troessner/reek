require 'reek/smells/smell_detector'
require 'reek/smell_warning'

module Reek
  module Smells

    # Checking for nil is a special kind of type check, and therefore a case of
    # SimulatedPolymorphism.
    class NilCheck < SmellDetector

      SMELL_CLASS = 'SimulatedPolymorphism'
      SMELL_SUBCLASS = self.name.split(/::/)[-1]

      def examine_context(ctx)
        call_nodes = CallNodeFinder.new(ctx)
        case_nodes = CaseNodeFinder.new(ctx)
        smelly_nodes = call_nodes.smelly + case_nodes.smelly

        smelly_nodes.map do |node|
          SmellWarning.new(SMELL_CLASS, ctx.full_name, Array(node.line),
                           "performs a nil-check.",
                           @source, SMELL_SUBCLASS)
        end
      end

      #
      # A base class that allows to work on all nodes of a certain type.
      #
      class NodeFinder
        SEXP_NIL = Sexp.new(:nil)
        def initialize(ctx, type)
          @nodes = Array(ctx.local_nodes(type))
        end
      end

      #
      # Find call nodes which perform a nil check.
      #
      class CallNodeFinder < NodeFinder
        def initialize(ctx)
          super(ctx, :call)
        end

        def smelly
          @nodes.select{ |call|
            nil_chk?(call) 
          }
        end

        def nil_chk?(call)
          nilQ_use?(call) || eq_nil_use?(call) 
        end

        def nilQ_use?(call)
          call.last == :nil?
        end

        def eq_nil_use?(call)
          include_eq?(call) && call.include?(SEXP_NIL)
        end

        def include_eq?(call)
          [:==, :===].any? { |operator| call.include?(operator) }
        end
      end

      #
      # Finds when statements that perform a nil check.
      #
      class CaseNodeFinder < NodeFinder
        CASE_NIL_NODE = Sexp.new(:array, SEXP_NIL)

        def initialize(ctx)
          super(ctx, :when)
        end

        def smelly
          @nodes.select{ |when_node|
            nil_chk?(when_node)
          }
        end

        def nil_chk?(when_node)
          when_node.include?(CASE_NIL_NODE)
        end
      end

    end
  end
end
