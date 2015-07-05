require_relative 'code_context'
require_relative '../ast/object_refs'

module Reek
  module Context
    #
    # The parameters in a method's definition.
    #
    # @api private
    module MethodParameters
      def default_assignments
        result = []
        each do |exp|
          result << exp[1..2] if exp.optional_argument?
        end
        result
      end
    end

    #
    # A context wrapper for any method definition found in a syntax tree.
    #
    # @api private
    class MethodContext < CodeContext
      attr_reader :parameters
      attr_reader :refs
      attr_reader :num_statements

      def initialize(outer, exp)
        super
        @parameters = exp.parameters.dup
        @parameters.extend MethodParameters
        @num_statements = 0
        @refs = AST::ObjectRefs.new
      end

      def count_statements(num)
        @num_statements += num
      end

      def record_call_to(exp)
        receiver, meth = exp[1..2]
        receiver ||= [:self]
        case receiver[0]
        when :lvasgn
          @refs.record_reference_to(receiver.name)
        when :lvar
          @refs.record_reference_to(receiver.name) unless meth == :new
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

      def references_self?
        exp.depends_on_instance?
      end

      def uses_param?(param)
        local_nodes(:lvar).find { |node| node.var_name == param.to_sym }
      end

      def unused_params
        exp.arguments.select do |param|
          next if param.anonymous_splat?
          next if param.marked_unused?
          !uses_param? param.plain_name
        end
      end

      def uses_super_with_implicit_arguments?
        (body = exp.body) && body.contains_nested_node?(:zsuper)
      end
    end
  end
end
