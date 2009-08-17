class Class
  def name_words
    class_name = name.split(/::/)[-1]
    class_name.gsub(/([a-z])([A-Z])/) { |sub| "#{$1} #{$2}"}.split
  end
end

module Reek
  module Smells

    class SmellDetector

      # The name of the config field that lists the names of code contexts
      # that should not be checked. Add this field to the config for each
      # smell that should ignore this code element.
      EXCLUDE_KEY = 'exclude'

      # The name fo the config field that specifies whether a smell is
      # enabled. Set to +true+ or +false+.
      ENABLED_KEY = 'enabled'

      # The name of the config field that sets scope-specific overrides
      # for other values in the current smell detector's configuration.
      EXCEPTIONS_KEY = 'exceptions'

      class << self
        def class_name
          self.name.split(/::/)[-1]
        end

        def contexts      # :nodoc:
          [:defn, :defs]
        end

        def default_config
          {
            ENABLED_KEY => true,
            EXCLUDE_KEY => []
          }
        end

        def create(config)
          new(config[class_name])
        end
      end

      def self.listen(hooks, config)
        detector = create(config)
        detector.listen_to(hooks)
        detector
      end

      def initialize(config = SmellDetector.default_config)
        @config = config
        @smells_found = Set.new
        @masked = false
      end

      def listen_to(hooks)
        self.class.contexts.each { |ctx| hooks[ctx] << self }
      end

      # SMELL: Getter
      def enabled?
        @config[ENABLED_KEY]
      end

      def configure(config)
        my_part = config[self.class.name.split(/::/)[-1]]
        return unless my_part
        configure_with(my_part)
      end

      def configure_with(config)
        @config.adopt!(config)
      end

      def copy
        self.class.new(@config.deep_copy)
      end

      def supersede_with(config)
        clone = self.copy
        @masked = true
        clone.configure_with(config)
        clone
      end

      def examine(context)
        before = @smells_found.size
        examine_context(context) if enabled? and !exception?(context)
        @smells_found.length > before
      end

      def examine_context(context)
      end
      
      def exception?(context)
        context.matches?(@config[EXCLUDE_KEY])
      end

      def found(scope, warning)
        smell = SmellWarning.new(self, scope, warning, @masked)
        @smells_found << smell
        smell
      end

      def has_smell?(patterns)
        return false if @masked
        @smells_found.each { |warning| return true if warning.contains_all?(patterns) }
        false
      end

      def report_on(report)
        @smells_found.each { |smell| smell.report_on(report) }
      end

      def num_smells
        @masked ? 0 : @smells_found.length
      end

      def smelly?
        (not @masked) and (@smells_found.length > 0)
      end

      def smell_name
        self.class.name_words.join(' ')
      end

      def value(key, ctx)
        if @config.has_key?(EXCEPTIONS_KEY)
          exc = @config[EXCEPTIONS_KEY].select {|hk,hv| ctx.matches?(hk)}
          if exc.length > 0
            conf = exc[0][1]
            if conf.has_key?(key)
              return conf[key]
            end
          end
        end
        return @config[key]
      end
    end
  end
end
