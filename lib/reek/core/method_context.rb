require 'reek/core/code_context'
require 'reek/core/object_refs'

module Reek
  module Core

    #
    # The parameters in a method's definition.
    #
    module MethodParameters
      def default_assignments
        result = []
        self[1..-1].each do |exp|
          result << exp[1..2] if Sexp === exp && exp[0] == :lasgn
        end
        result
      end
    end

    #
    # A context wrapper for any method definition found in a syntax tree.
    #
    class MethodContext < CodeContext
      attr_reader :parameters
      attr_reader :refs
      attr_reader :num_statements

      def initialize(outer, exp)
        super(outer, exp)
        @parameters = exp[exp[0] == :defn ? 2 : 3]  # SMELL: SimulatedPolymorphism
        @parameters ||= []
        @parameters.extend(MethodParameters)
        @num_statements = 0
        @refs = ObjectRefs.new
      end

      def count_statements(num)
        @num_statements += num
      end

      def record_call_to(exp)
        receiver, meth = exp[1..2]
        receiver ||= [:self]
        case receiver[0]
        when :lvar
          @refs.record_reference_to(receiver) unless meth == :new
        when :self
          @refs.record_reference_to(:self)
        end
      end

      def record_use_of_self
        @refs.record_reference_to(:self)
      end

      def envious_receivers
        return [] if @refs.self_is_max?
        @refs.max_keys
      end

      def uses_param?(param)
        local_nodes(:lvar).include?(Sexp.new(:lvar, param.to_sym))
      end
    end
  end
end
