require_relative '../smells'
require_relative 'smell_detector'
require_relative '../configuration/app_configuration'

module Reek
  module Smells
    #
    # Contains all the existing smells and exposes operations on them.
    #
    class SmellRepository
      private_attr_reader :configuration, :smell_types, :detectors

      def self.smell_types
        Reek::Smells::SmellDetector.descendants.sort_by(&:name)
      end

      def self.eligible_smell_types(filter_by_smells = [])
        return smell_types if filter_by_smells.empty?
        smell_types.select do |klass|
          filter_by_smells.include? klass.smell_type
        end
      end

      def initialize(smell_types: self.class.smell_types,
                     configuration: {})
        @configuration = configuration
        @smell_types   = smell_types
        @detectors     = smell_types.map { |klass| klass.new configuration_for(klass) }
      end

      def report_on(collector)
        detectors.each { |detector| detector.report_on(collector) }
      end

      def examine(context)
        smell_detectors_for(context.type).each do |detector|
          detector.run_for(context)
        end
      end

      private

      def configuration_for(klass)
        configuration.fetch klass, {}
      end

      def smell_detectors_for(type)
        enabled_detectors.select do |detector|
          detector.contexts.include? type
        end
      end

      def enabled_detectors
        detectors.select { |detector| detector.config.enabled? }
      end
    end
  end
end
