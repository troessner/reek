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
        examine_context(context, report) if @enabled
        report.length > before
      end

      def examine_context(context, report)
      end
      
      def exception?(val)
        @exceptions.include?(val)
      end
    end

    class SmellReport
      include Comparable

      def initialize(context)
        @context = context
      end

      def detailed_report
        "#{@context.to_s} #{warning}"
      end

      def hash  # :nodoc:
        report.hash
      end

      def <=>(other)  # :nodoc:
        Options[:sort_order].compare(self, other)
      end

      alias eql? <=>

      def self.smell_name
        name_words[0..-2].join(' ')
      end

      def report
        "[#{self.class.smell_name}] #{detailed_report}"
      end

      alias inspect report
    end
  end
end
