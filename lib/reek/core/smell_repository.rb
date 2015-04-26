require_relative '../smells'
require_relative '../smells/smell_detector'
require_relative '../configuration/app_configuration'

module Reek
  module Core
    #
    # Contains all the existing smells and exposes operations on them.
    #
    class SmellRepository
      attr_reader :detectors

      def self.smell_types
        Reek::Smells::SmellDetector.descendants.sort_by(&:name)
      end

      def initialize(source_description = nil, smell_types = self.class.smell_types)
        @typed_detectors = nil
        @detectors = {}
        smell_types.each do |klass|
          @detectors[klass] = klass.new(source_description)
        end
        Configuration::AppConfiguration.configure_smell_repository self
      end

      def configure(klass, config)
        detector = @detectors[klass]
        raise ArgumentError, "Unknown smell type #{klass} found in configuration" unless detector
        detector.configure_with(config)
      end

      def report_on(listener)
        @detectors.each_value { |detector| detector.report_on(listener) }
      end

      def examine(scope, node_type)
        smell_listeners[node_type].each do |detector|
          detector.examine(scope)
        end
      end

      private

      def smell_listeners
        unless @typed_detectors
          @typed_detectors = Hash.new { |hash, key| hash[key] = [] }
          @detectors.each_value { |detector| detector.register(@typed_detectors) }
        end
        @typed_detectors
      end
    end
  end
end
