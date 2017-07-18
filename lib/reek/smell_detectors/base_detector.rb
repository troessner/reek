# frozen_string_literal: true

require 'set'
require_relative '../smell_warning'
require_relative '../smell_configuration'

module Reek
  module SmellDetectors
    #
    # Shared responsibilities of all smell detectors.
    #
    # See
    #   - {file:docs/Basic-Smell-Options.md}
    #   - {file:docs/Code-Smells.md}
    #   - {file:README.md}
    # for details.
    #
    # :reek:UnusedPrivateMethod: { exclude: [ smell_warning ] }
    # :reek:TooManyMethods: { max_methods: 18 }
    class BaseDetector
      attr_reader :config
      # The name of the config field that lists the names of code contexts
      # that should not be checked. Add this field to the config for each
      # smell that should ignore this code element.
      EXCLUDE_KEY = 'exclude'.freeze

      # The default value for the +EXCLUDE_KEY+ if it isn't specified
      # in any configuration file.
      DEFAULT_EXCLUDE_SET = [].freeze

      def initialize(configuration: {}, context: nil)
        @config = SmellConfiguration.new self.class.default_config.merge(configuration)
        @context = context
      end

      def smell_type
        self.class.smell_type
      end

      def run
        return [] unless enabled?
        return [] if exception?

        sniff(context)
      end

      def self.todo_configuration_for(smells)
        default_exclusions = default_config.fetch 'exclude'
        exclusions = default_exclusions + smells.map(&:context)
        { smell_type => { 'exclude' => exclusions.uniq } }
      end

      private

      attr_reader :context

      def exception?
        context.matches?(value(EXCLUDE_KEY, context))
      end

      def enabled?
        config.enabled? && config_for(context)[SmellConfiguration::ENABLED_KEY] != false
      end

      def value(key, ctx)
        config_for(ctx)[key] || config.value(key, ctx)
      end

      def config_for(ctx)
        ctx.config_for(self.class)
      end

      # :reek:FeatureEnvy
      def smell_warning(options = {})
        context = options.fetch(:context)
        exp = context.exp
        SmellWarning.new(self,
                         source: exp.source,
                         context: context.full_name,
                         lines: options.fetch(:lines),
                         message: options.fetch(:message),
                         parameters: options.fetch(:parameters, {}))
      end

      class << self
        def smell_type
          @smell_type ||= name.split(/::/).last
        end

        def contexts
          [:def, :defs]
        end

        # :reek:UtilityFunction
        def default_config
          {
            SmellConfiguration::ENABLED_KEY => true,
            EXCLUDE_KEY => DEFAULT_EXCLUDE_SET.dup
          }
        end

        def inherited(subclass)
          descendants << subclass
        end

        #
        # Returns all descendants of BaseDetector
        #
        # @return [Array<Constant>], e.g.:
        #   [Reek::SmellDetectors::Attribute,
        #    Reek::SmellDetectors::BooleanParameter,
        #    Reek::SmellDetectors::ClassVariable,
        #    ...]
        #
        def descendants
          @descendants ||= []
        end

        #
        # @param detector [String] the detector in question, e.g. 'DuplicateMethodCall'
        # @return [Boolean]
        #
        def valid_detector?(detector)
          descendants.map { |descendant| descendant.to_s.split('::').last }.
            include?(detector)
        end

        #
        # Transform a detector name to the corresponding constant.
        # Note that we assume a valid name - exceptions are not handled here.
        #
        # @param detector_name [String] the detector in question, e.g. 'DuplicateMethodCall'
        # @return [SmellDetector] - this will return the class, not an instance
        #
        def to_detector(detector_name)
          SmellDetectors.const_get detector_name
        end

        #
        # @return [Set<Symbol>] - all configuration keys that are available for this detector
        #
        def configuration_keys
          Set.new(default_config.keys.map(&:to_sym))
        end
      end
    end
  end
end
