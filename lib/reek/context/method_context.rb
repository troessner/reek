# frozen_string_literal: true

require_relative 'code_context'

module Reek
  module Context
    #
    # A context wrapper for any method definition found in a syntax tree.
    #
    # @quality :reek:Attribute
    class MethodContext < CodeContext
      attr_accessor :visibility
      attr_reader :refs

      def initialize(exp, parent_exp)
        @parent_exp = parent_exp
        @visibility = :public
        super exp
      end

      def references_self?
        exp.depends_on_instance?
      end

      def uses_param?(param)
        # :lvasgn catches:
        #
        #   def foo(bar); bar += 1; end
        #
        # :lvar catches:
        #
        #   def foo(bar); other(bar); end
        #   def foo(bar); tmp = other(bar); tmp[0]; end
        #
        local_nodes([:lvar, :lvasgn]).find { |node| node.var_name == param.name }
      end

      # @quality :reek:FeatureEnvy
      def unused_params
        exp.arguments.reject do |param|
          param.anonymous_splat? ||
            param.marked_unused? ||
            uses_param?(param)
        end
      end

      def uses_super_with_implicit_arguments?
        (body = exp.body) && body.contains_nested_node?(:zsuper)
      end

      def default_assignments
        @default_assignments ||=
          exp.parameters.select(&:optional_argument?).map(&:children)
      end

      def method_context_class
        self.class
      end

      def singleton_method?
        false
      end

      def instance_method?
        true
      end

      def apply_current_visibility(current_visibility)
        self.visibility = current_visibility
      end

      def module_function?
        visibility == :module_function
      end

      def non_public_visibility?
        visibility != :public
      end

      def full_comment
        own = super
        return own unless own.empty?
        return parent_exp.full_comment if parent_exp

        ''
      end

      private

      attr_reader :parent_exp
    end
  end
end
