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
      # @return [Array<SmellWarning>]
      #
      def sniff
        hits.map do |hit|
          name = hit.name
          smell_warning(
            context: context,
            lines: [hit.line],
            message: "has the unused private instance method '#{name}'",
            parameters: { name: name.to_s })
        end
      end

      private

      #
      # @return [Array<Hit>]
      #
      def hits
        unused_private_methods.map do |defined_method|
          Hit.new(defined_method) unless ignore_method?(defined_method)
        end.compact
      end

      #
      # @return [Array<Context::MethodContext]
      #
      def unused_private_methods
        defined_private_methods = context.defined_instance_methods(visibility: :private)
        called_method_names     = context.instance_method_calls.map(&:name)

        defined_private_methods.reject do |defined_method|
          called_method_names.include?(defined_method.name)
        end
      end

      #
      # @param method [Context::MethodContext]
      # @return [Boolean]
      #
      def ignore_method?(method)
        # ignore_contexts will be e.g. ["Foo::Smelly#my_method", "..."]
        ignore_contexts = value(EXCLUDE_KEY, context)
        ignore_contexts.any? do |ignore_context|
          full_name = "#{method.parent.full_name}##{method.name}"
          full_name[ignore_context]
        end
      end
    end
  end
end
