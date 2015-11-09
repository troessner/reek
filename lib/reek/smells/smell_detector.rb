require 'set'
require_relative 'smell_configuration'

module Reek
  module Smells
    #
    # Shared responsibilities of all smell detectors.
    #
    # See
    #   - {file:docs/Basic-Smell-Options.md}
    #   - {file:docs/Code-Smells.md}
    #   - {file:README.md}
    # for details.
    #
    # :reek:TooManyMethods: { max_methods: 19 }
    # :reek:TooManyInstanceVariables: { max_instance_variables: 5 }
    class SmellDetector
      attr_reader :config
      private_attr_accessor :smells_found
      # The name of the config field that lists the names of code contexts
      # that should not be checked. Add this field to the config for each
      # smell that should ignore this code element.
      EXCLUDE_KEY = 'exclude'

      # The default value for the +EXCLUDE_KEY+ if it isn't specified
      # in any configuration file.
      DEFAULT_EXCLUDE_SET = []

      def initialize(config = {})
        @config       = SmellConfiguration.new self.class.default_config.merge(config)
        @smells_found = []
      end

      def smell_category
        self.class.smell_category
      end

      def smell_type
        self.class.smell_type
      end

      def contexts
        self.class.contexts
      end

      def run_for(context)
        return unless enabled_for?(context)
        return if exception?(context)

        self.smells_found = smells_found + inspect(context)
      end

      def report_on(collector)
        smells_found.each { |smell| smell.report_on(collector) }
      end

      def exception?(context)
        context.matches?(value(EXCLUDE_KEY, context, DEFAULT_EXCLUDE_SET))
      end

      private

      def enabled_for?(context)
        config.enabled? && config_for(context)[SmellConfiguration::ENABLED_KEY] != false
      end

      def value(key, ctx, fall_back)
        config_for(ctx)[key] || config.value(key, ctx, fall_back)
      end

      def config_for(ctx)
        ctx.config_for(self.class)
      end

      # :reek:FeatureEnvy
      def smell_warning(options = {})
        context = options.fetch(:context)
        exp = context.exp
        ctx_source = exp.loc.expression.source_buffer.name
        SmellWarning.new(self,
                         source: ctx_source,
                         context: context.full_name,
                         lines: options.fetch(:lines),
                         message: options.fetch(:message),
                         parameters: options.fetch(:parameters, {}))
      end

      class << self
        def smell_category
          @smell_category ||= default_smell_category
        end

        def smell_type
          @smell_type ||= default_smell_category
        end

        def default_smell_category
          name.split(/::/)[-1]
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

        def descendants
          @descendants ||= []
        end
      end
    end
  end
end
