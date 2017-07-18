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
    # :reek:TooManyMethods: { max_methods: 22 }
    class BaseDetector
      attr_reader :config
      # The name of the config field that lists the names of code contexts
      # that should not be checked. Add this field to the config for each
      # smell that should ignore this code element.
      EXCLUDE_KEY = 'exclude'.freeze

      # The default value for the +EXCLUDE_KEY+ if it isn't specified
      # in any configuration file.
      DEFAULT_EXCLUDE_SET = [].freeze

      def initialize(config = {})
        @config = SmellConfiguration.new self.class.default_config.merge(config)
      end

      def smell_type
        self.class.smell_type
      end

      def contexts
        self.class.contexts
      end

      def run_for(context)
        check_for_unnecessary_suppression(sniff(context), context)
      end

      def exception?(context)
        context.matches?(value(EXCLUDE_KEY, context))
      end

      def self.todo_configuration_for(smells)
        default_exclusions = default_config.fetch 'exclude'
        exclusions = default_exclusions + smells.map(&:context)
        { smell_type => { 'exclude' => exclusions.uniq } }
      end

      private

      def check_for_unnecessary_suppression(results, context)
        if unnecessarily_suppressed?(results, context)
          [unnecessary_suppression_warning(context: context)]
        elsif exception_or_disabled_for?(context)
          []
        else
          results
        end
      end

      def unnecessarily_suppressed?(results, context)
        Array(results).empty? &&
          exception_or_disabled_for?(context) &&
          enabled_and_included_by_default?(context)
      end

      def exception_or_disabled_for?(context)
        disabled_for?(context) || exception?(context)
      end

      def disabled_for?(context)
        config_for(context)[SmellConfiguration::ENABLED_KEY] == false
      end

      def enabled_and_included_by_default?(context)
        defaults = self.class.default_config
        defaults.fetch('enabled') && !context.matches?(defaults.fetch('exclude', []))
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

      def unnecessary_suppression_warning(options = {})
        smell_warning(context: options.fetch(:context),
                      lines: [],
                      message: 'is unnecessarily suppressed')
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
