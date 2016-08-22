# frozen_string_literal: true
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods or lines of code.
    #
    # +TooManyInstanceVariables' reports classes having more than a
    # configurable number of instance variables.
    #
    # See {file:docs/Too-Many-Instance-Variables.md} for details.
    class TooManyInstanceVariables < SmellDetector
      # The name of the config field that sets the maximum number of instance
      # variables permitted in a class.
      MAX_ALLOWED_IVARS_KEY = 'max_instance_variables'.freeze
      DEFAULT_MAX_IVARS = 4

      def self.contexts
        [:class]
      end

      def self.default_config
        super.merge(
          MAX_ALLOWED_IVARS_KEY => DEFAULT_MAX_IVARS,
          EXCLUDE_KEY => [])
      end

      #
      # Checks +klass+ for too many instance variables.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(ctx)
        max_allowed_ivars = value(MAX_ALLOWED_IVARS_KEY, ctx)

        count = count_instance_variables(ctx)

        return [] if count <= max_allowed_ivars

        [smell_warning(
          context: ctx,
          lines: [ctx.exp.line],
          message: "has at least #{count} instance variables",
          parameters: { count: count })]
      end

      private

      def count_instance_variables(ctx)
        ctx.each_node(:ivasgn, ignored_nodes).map do |node|
          node.children.first
        end.uniq.size
      end

      def ignored_nodes
        [:or_asgn, :class, :module]
      end
    end
  end
end
