require File.join(File.dirname(File.expand_path(__FILE__)), 'code_context')
require File.join(File.dirname(File.expand_path(__FILE__)), 'object_refs')

module Reek
  module Core

    #
    # The parameters in a method's definition.
    #
    module MethodParameters
      def default_assignments
        assignments = self[-1]
        result = []
        return result unless is_assignment_block?(assignments)
        assignments[1..-1].each do |exp|
          result << exp[1..2] if exp[0] == :lasgn
        end
        result
      end
      def is_arg?(param)
        return false if is_assignment_block?(param)
        return !(param.to_s =~ /^\&/)
      end
      def is_assignment_block?(param)
        Array === param and param[0] == :block
      end

      def names
        return @names if @names
        @names = self[1..-1].select {|arg| is_arg?(arg)}.map {|arg| arg.to_s }
      end

      def length
        names.length
      end

      def include?(name)
        names.include?(name)
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
          @refs.record_ref(receiver) unless meth == :new
        when :self
          record_use_of_self
        end
      end

      def record_use_of_self
        @refs.record_reference_to_self
      end

      def envious_receivers
        return [] if @refs.self_is_max?
        @refs.max_keys
      end
    end
  end
end
