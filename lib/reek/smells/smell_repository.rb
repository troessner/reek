require_relative '../smells'
require_relative 'smell_detector'
require_relative '../configuration/app_configuration'

module Reek
  module Smells
    #
    # Contains all the existing smells and exposes operations on them.
    #
    # @api private
    class SmellRepository
      def self.smell_types
        Reek::Smells::SmellDetector.descendants.sort_by(&:name)
      end

      def initialize(source_description: nil,
                     smell_types: self.class.smell_types,
                     configuration: Configuration::AppConfiguration.new)
        self.source_via         = source_description
        self.typed_detectors    = nil
        self.configuration      = configuration
        self.smell_types        = smell_types

        configuration.directive_for(source_via).each do |klass, config|
          configure klass, config
        end
      end

      def configure(klass, config)
        detector = detectors[klass]
        raise ArgumentError, "Unknown smell type #{klass} found in configuration" unless detector
        detector.configure_with(config)
      end

      def report_on(listener)
        detectors.each_value { |detector| detector.report_on(listener) }
      end

      def examine(scope)
        smell_listeners[scope.type].each do |detector|
          detector.examine(scope)
        end
      end

      def detectors
        @initialized_detectors ||= begin
          @detectors = {}
          smell_types.each do |klass|
            @detectors[klass] = klass.new(source_via)
          end
          @detectors
        end
      end

      private

      attr_accessor :typed_detectors, :configuration, :source_via, :smell_types

      def smell_listeners
        unless typed_detectors
          self.typed_detectors = Hash.new { |hash, key| hash[key] = [] }
          detectors.each_value { |detector| detector.register(typed_detectors) }
        end
        typed_detectors
      end
    end
  end
end
