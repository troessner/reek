# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # Classes should use their private methods. Otherwise this is dead
    # code which is confusing and bad for maintenance.
    #
    # See {file:docs/Unused-Private-Method.md} for details.
    #
    class UnusedPrivateMethod < BaseDetector
      def self.default_config
        super.merge(SmellConfiguration::ENABLED_KEY => false)
      end

      # Class for storing `hits` which are unused private methods
      # we found in the given context. `name` and `line` are then used to
      # construct SmellWarnings.
      class Hit
        attr_reader :name, :line

        def initialize(context)
          @name  = context.name
          @line  = context.exp.line
        end
      end

      def self.contexts
        [:class]
      end

      #
      # @param ctx [Context::ClassContext]
      # @return [Array<SmellWarning>]
      #
      # :reek:FeatureEnvy
      def sniff(ctx)
        hits(ctx).map do |hit|
          name = hit.name
          smell_warning(
            context: ctx,
            lines: [hit.line],
            message: "has the unused private instance method '#{name}'",
            parameters: { name: name.to_s })
        end
      end

      private

      #
      # @param ctx [Context::ClassContext]
      # @return [Array<Hit>]
      #
      def hits(ctx)
        unused_private_methods(ctx).map do |defined_method|
          Hit.new(defined_method) unless ignore_method?(ctx, defined_method)
        end.compact
      end

      #
      # @param ctx [Context::ClassContext]
      # @return [Array<Context::MethodContext]
      #
      # :reek:UtilityFunction
      def unused_private_methods(ctx)
        defined_private_methods = ctx.defined_instance_methods(visibility: :private)
        called_method_names     = ctx.instance_method_calls.map(&:name)

        defined_private_methods.reject do |defined_method|
          called_method_names.include?(defined_method.name)
        end
      end

      #
      # @param ctx [Context::ClassContext]
      # @param method [Context::MethodContext]
      # @return [Boolean]
      #
      # :reek:FeatureEnvy
      def ignore_method?(ctx, method)
        # ignore_contexts will be e.g. ["Foo::Smelly#my_method", "..."]
        ignore_contexts = value(EXCLUDE_KEY, ctx)
        ignore_contexts.any? do |ignore_context|
          full_name = "#{method.parent.full_name}##{method.name}"
          full_name[ignore_context]
        end
      end
    end
  end
end
