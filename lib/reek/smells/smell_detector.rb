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
      
      def self.class_name
        self.name.split(/::/)[-1]
      end

      def self.contexts      # :nodoc:
        [:defn, :defs]
      end
      
      def self.default_config
        {
          ENABLED_KEY => true,
          EXCLUDE_KEY => []
        }
      end

      def self.create(config)
        new(config[class_name])
      end

      def self.listen(hooks, config)
        detector = create(config)
        contexts.each { |ctx| hooks[ctx] << detector }
        detector
      end

      def initialize(config)
        @enabled = config[ENABLED_KEY]
        @exceptions = config[EXCLUDE_KEY]
        @smells_found = []
        @masked = false
      end

      def be_masked
        @masked = true
      end

      def enabled?
        @enabled
      end

      def configure(config)
        my_part = config[self.class.name.split(/::/)[-1]]
        return unless my_part
        configure_with(my_part)
      end

      def configure_with(config)
        @enabled = config[ENABLED_KEY]  # if config.has_key?(ENABLED_KEY)
      end

      def examine(context)
        before = @smells_found.size
        examine_context(context) if @enabled and !exception?(context)
        @smells_found.length > before
      end

      def examine_context(context)
      end
      
      def exception?(context)
        return false if @exceptions.nil? or @exceptions.length == 0
        context.matches?(@exceptions)
      end

      def found(scope, warning)
        smell = SmellWarning.new(self, scope, warning)
        @smells_found << smell
        smell
      end

      def report_on(report)
        @smells_found.each do |smell|
          if @masked
            report.record_masked_smell(smell)
          else
            report << smell
          end
        end
      end

      def smell_name
        self.class.name_words.join(' ')
      end
    end
  end
end
