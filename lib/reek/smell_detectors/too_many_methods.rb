# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
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
    #
    # @quality :reek:TooManyConstants { max_constants: 11 }
    class TooManyMethods < BaseDetector
      # The name of the config field that sets the maximum number of methods
      # permitted in a class.
      MAX_ALLOWED_METHODS_KEY = 'max_methods'
      DEFAULT_MAX_METHODS = 15

      # The names of the config fields that set the maximum number of methods
      # permitted in a class for one particular visibility.
      MAX_PUBLIC_METHODS_KEY                = 'max_public_methods'
      MAX_PROTECTED_METHODS_KEY             = 'max_protected_methods'
      MAX_PRIVATE_METHODS_KEY               = 'max_private_methods'
      MAX_PRIVATE_AND_PROTECTED_METHODS_KEY = 'max_private_and_protected_methods'

      # The names of the config fields that keep one particular visibility out
      # of every count.
      IGNORE_PUBLIC_METHODS_KEY    = 'ignore_public_methods'
      IGNORE_PROTECTED_METHODS_KEY = 'ignore_protected_methods'
      IGNORE_PRIVATE_METHODS_KEY   = 'ignore_private_methods'

      # Maps each visibility to the config field that keeps it out of every count.
      IGNORE_KEYS = {
        public:    IGNORE_PUBLIC_METHODS_KEY,
        protected: IGNORE_PROTECTED_METHODS_KEY,
        private:   IGNORE_PRIVATE_METHODS_KEY
      }.freeze

      # Maps each visibility specific config field to the visibilities it counts.
      VISIBILITY_THRESHOLD_KEYS = {
        MAX_PUBLIC_METHODS_KEY                => [:public],
        MAX_PROTECTED_METHODS_KEY             => [:protected],
        MAX_PRIVATE_METHODS_KEY               => [:private],
        MAX_PRIVATE_AND_PROTECTED_METHODS_KEY => [:private, :protected]
      }.freeze

      def self.contexts
        [:class]
      end

      def self.default_config
        super.merge(
          MAX_ALLOWED_METHODS_KEY               => DEFAULT_MAX_METHODS,
          MAX_PUBLIC_METHODS_KEY                => nil,
          MAX_PROTECTED_METHODS_KEY             => nil,
          MAX_PRIVATE_METHODS_KEY               => nil,
          MAX_PRIVATE_AND_PROTECTED_METHODS_KEY => nil,
          IGNORE_PUBLIC_METHODS_KEY             => false,
          IGNORE_PROTECTED_METHODS_KEY          => false,
          IGNORE_PRIVATE_METHODS_KEY            => false,
          EXCLUDE_KEY                           => [])
      end

      # Checks context for too many methods
      # @return [Array<SmellWarning>]
      def sniff
        [general_smell, *visibility_smells].compact.uniq
      end

      private

      def general_smell
        actual = general_methods_count
        return if actual <= value(MAX_ALLOWED_METHODS_KEY, context)

        smell_warning_for(actual, 'methods')
      end

      def visibility_smells
        VISIBILITY_THRESHOLD_KEYS.filter_map do |key, visibilities|
          visibility_smell(counted_visibilities(visibilities), value(key, context))
        end
      end

      def visibility_smell(visibilities, max_allowed)
        return unless max_allowed && visibilities.any?

        actual = methods_with_visibilities(visibilities).length
        return if actual <= max_allowed

        smell_warning_for(actual, "#{visibilities.join(' and ')} methods")
      end

      def counted_visibilities(visibilities)
        visibilities.reject { |visibility| ignore?(visibility) }
      end

      def general_methods_count
        # TODO: Only checks instance methods!
        context.node_instance_methods.length -
          methods_with_visibilities(ignored_visibilities).length
      end

      def ignored_visibilities
        IGNORE_KEYS.each_key.select { |visibility| ignore?(visibility) }
      end

      def ignore?(visibility)
        value(IGNORE_KEYS.fetch(visibility), context)
      end

      def methods_with_visibilities(visibilities)
        defined_methods.select { |method| visibilities.include?(method.visibility) }
      end

      # @return [Array<Context::MethodContext>] the same methods `node_instance_methods`
      #   counts, as contexts, which is what knows about visibility
      def defined_methods
        @defined_methods ||= context.children.select { |child| child.exp.type == :def }
      end

      def smell_warning_for(count, counted)
        smell_warning(
          lines: [source_line],
          message: "has at least #{count} #{counted}",
          parameters: { count: count })
      end
    end
  end
end
