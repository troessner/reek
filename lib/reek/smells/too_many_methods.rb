# frozen_string_literal: true
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # A Large Class is a class or module that has a large number of
    # instance variables, methods or lines of code.
    #
    # +TooManyMethods+ reports classes having more than a configurable number
    # of methods. The method count includes public, protected and private
    # methods, and excludes methods inherited from superclasses or included
    # modules.
    #
    # See {file:docs/Too-Many-Methods.md} for details.
    class TooManyMethods < SmellDetector
      # The name of the config field that sets the maximum number of methods
      # permitted in a class.
      MAX_ALLOWED_METHODS_KEY = 'max_methods'.freeze
      DEFAULT_MAX_METHODS = 15

      def self.contexts
        [:class]
      end

      def self.default_config
        super.merge(
          MAX_ALLOWED_METHODS_KEY => DEFAULT_MAX_METHODS,
          EXCLUDE_KEY => [])
      end

      #
      # Checks +ctx+ for too many methods
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(ctx)
        max_allowed_methods = value(MAX_ALLOWED_METHODS_KEY, ctx)
        # TODO: Only checks instance methods!
        actual = ctx.node_instance_methods.length
        return [] if actual <= max_allowed_methods
        [smell_warning(
          context: ctx,
          lines: [ctx.exp.line],
          message: "has at least #{actual} methods",
          parameters: { count: actual })]
      end
    end
  end
end
