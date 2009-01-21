$:.unshift File.dirname(__FILE__)

require 'reek/options'

class Class
  def name_words
    class_name = name.split(/::/)[-1]
    class_name.gsub(/([a-z])([A-Z])/) { |sub| "#{$1} #{$2}"}.split
  end
end

module Reek
  module Smells

    class SmellDetector
      
      def self.class_name
        self.name.split(/::/)[-1]
      end

      def self.contexts      # :nodoc:
        [:defn, :defs]
      end

      def self.listen(hooks, config)
        detector = new(config[class_name])
        contexts.each { |ctx| hooks[ctx] << detector }
      end

      def initialize(config)
        @enabled = config.fetch('enabled', true)
        @exceptions = config.fetch('exceptions', [])
      end

      def examine(context, report)
        before = report.size
        examine_context(context, report) if @enabled and !exception?(context)
        report.length > before
      end

      def examine_context(context, report)
      end
      
      def exception?(context)
#        puts "#{@exceptions.inspect} === #{context}" if smell_name == 'Feature Envy'
        return false if @exceptions.length == 0
        context.matches?(@exceptions)
      end

      def smell_name
        self.class.name_words.join(' ')
      end
    end

    #
    # Reports a warning that a smell has been found.
    #
    class SmellWarning
      include Comparable

      def initialize(smell, context, warning)
        @smell = smell
        @context = context
        @warning = warning
      end

      def detailed_report
        "#{@context} #{@warning}"
      end

      def hash  # :nodoc:
        report.hash
      end

      def <=>(other)  # :nodoc:
        Options[:sort_order].compare(self, other)
      end

      alias eql? <=>

      def report
        "[#{@smell}] #{detailed_report}"
      end

      alias inspect report
    end
  end
end
