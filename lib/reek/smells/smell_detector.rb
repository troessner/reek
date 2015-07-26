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
    #   - {file:docs/Configuration-Files.md}
    # for details.
    #
    # @api private
    class SmellDetector
      attr_reader :source

      # The name of the config field that lists the names of code contexts
      # that should not be checked. Add this field to the config for each
      # smell that should ignore this code element.
      EXCLUDE_KEY = 'exclude'

      # The default value for the +EXCLUDE_KEY+ if it isn't specified
      # in any configuration file.
      DEFAULT_EXCLUDE_SET = []

      class << self
        def contexts
          [:def, :defs]
        end

        def default_config
          {
            SmellConfiguration::ENABLED_KEY => true,
            EXCLUDE_KEY => DEFAULT_EXCLUDE_SET.dup
          }
        end

        def inherited(subclass)
          subclasses << subclass
        end

        def descendants
          subclasses
        end

        private

        def subclasses
          @subclasses ||= []
        end
      end

      def smell_category
        self.class.smell_category
      end

      def smell_type
        self.class.smell_type
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
      end

      attr_reader :smells_found   # SMELL: only published for tests

      def initialize(source, config = self.class.default_config)
        @source = source
        @config = SmellConfiguration.new(config)
        @smells_found = []
      end

      def register(hooks)
        return unless config.enabled?
        self.class.contexts.each { |ctx| hooks[ctx] << self }
      end

      # SMELL: Getter (only used in 1 test)
      def enabled?
        config.enabled?
      end

      def configure_with(new_config)
        config.merge!(new_config)
      end

      def examine(context)
        return unless enabled_for? context
        return if exception?(context)

        sm = examine_context(context)
        self.smells_found += sm
      end

      def enabled_for?(context)
        enabled? && config_for(context)[SmellConfiguration::ENABLED_KEY] != false
      end

      def exception?(context)
        context.matches?(value(EXCLUDE_KEY, context, DEFAULT_EXCLUDE_SET))
      end

      def report_on(report)
        smells_found.each { |smell| smell.report_on(report) }
      end

      def value(key, ctx, fall_back)
        config_for(ctx)[key] || config.value(key, ctx, fall_back)
      end

      def config_for(ctx)
        ctx.config_for(self.class)
      end

      protected

      attr_writer :smells_found

      private

      private_attr_reader :config
    end
  end
end
