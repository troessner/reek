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

      def self.listen(hooks, config)
        detector = new(config[class_name])
        contexts.each { |ctx| hooks[ctx] << detector }
      end

      def initialize(config)
        @enabled = config[ENABLED_KEY]
        @exceptions = config[EXCLUDE_KEY]
      end

      def examine(context, report)
        before = report.size
        examine_context(context, report) if @enabled and !exception?(context)
        report.length > before
      end

      def examine_context(context, report)
      end
      
      def exception?(context)
        return false if @exceptions.nil? or @exceptions.length == 0
        context.matches?(@exceptions)
      end

      def smell_name
        self.class.name_words.join(' ')
      end
    end
  end
end
