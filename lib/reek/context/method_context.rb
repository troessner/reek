require_relative 'code_context'

module Reek
  module Context
    #
    # A context wrapper for any method definition found in a syntax tree.
    #
    # @api private
    class MethodContext < CodeContext
      attr_reader :refs

      def envious_receivers
        return {} if refs.self_is_max?
        refs.most_popular
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

      def default_assignments
        @default_assignments ||=
          exp.parameters.select(&:optional_argument?).map(&:children)
      end
    end
  end
end
