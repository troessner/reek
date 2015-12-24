require_relative 'smell_detector'
require_relative 'smell_warning'
require_relative '../context/method_context'
require_relative '../context/singleton_method_context'

module Reek
  module Smells
    # Class for storing `hits` which are unused private methods
    # we found in the given context. `name`, `line` and `scope` are then used to
    # construct SmellWarnings.
    class Hit
      attr_reader :name, :scope, :line

      def initialize(context)
        @name  = context.name
        @scope = context.class == Context::SingletonMethodContext ? 'class' : 'instance'
        @line  = context.exp.line
      end
    end

    #
    # Classes should use their private methods otherwise this is dead
    # code, which is confusing, error-prone and bad for maintenance.
    #
    # See {file:docs/Unused-Private-Method.md} for details.
    class UnusedPrivateMethod < SmellDetector
      def self.contexts
        [:class]
      end

      #
      # @param ctx [Context::ClassContext]
      # @return [Array<SmellWarning>]
      #
      # :reek:FeatureEnvy
      #
      def inspect(ctx)
        hits(ctx).map do |hit|
          name = hit.name
          smell_warning(
            context: ctx,
            lines: [hit.line],
            message: "has the unused private #{hit.scope} method `#{name}`",
            parameters: { name: name })
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
      # @return [Array<Context::MethodContext | Context::SingletonMethodContext>]
      #
      # :reek:UtilityFunction
      # :reek:NestedIterators: { max_allowed_nesting: 2 }
      def unused_private_methods(ctx)
        defined_private_methods = ctx.defined_methods(visibility: :private)
        called_methods          = ctx.method_calls

        defined_private_methods.select do |defined_method|
          called_methods.none? do |called_method|
            MethodComparator.new(called_method, defined_method).pair?
          end
        end
      end

      #
      # @param ctx [Context::ClassContext]
      # @return [Boolean]
      #
      def ignore_method?(ctx, method)
        ignore_methods = value(EXCLUDE_KEY, ctx, DEFAULT_EXCLUDE_SET)
        ignore_methods.any? { |ignore_method| method.name[ignore_method] }
      end

      # MethodComparator compares a called method and a defined method
      # and tries to find out if they are a pair.
      class MethodComparator
        private_attr_reader :called_method, :defined_method,
                            :class_scope, :instance_scope
        #
        # @param called_method [Context::SendContext]
        # @param defined_method [Context::MethodContext | Context::SingletonMethodContext]
        #
        def initialize(called_method, defined_method)
          @called_method  = called_method
          @defined_method = defined_method
          @class_scope    = Context::SingletonMethodContext
          @instance_scope = Context::MethodContext
        end

        def pair?
          same_name? && same_scope?
        end

        private

        def same_name?
          called_method.name == defined_method.name
        end

        def same_scope?
          class_scope? || instance_scope?
        end

        def class_scope?
          defined_method.class == class_scope &&
            called_method.parent.class == class_scope
        end

        def instance_scope?
          defined_method.class == instance_scope &&
            called_method.parent.class == instance_scope
        end
      end
    end
  end
end
