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

      def initialize(smell_types: self.class.smell_types,
                     configuration: {})
        @configuration = configuration
        @smell_types   = smell_types
      end

      def report_on(listener)
        detectors.each_value { |detector| detector.report_on(listener) }
      end

      def examine(context)
        smell_listeners[context.type].each do |detector|
          detector.examine(context)
        end
      end

      def detectors
        @initialized_detectors ||= smell_types.map do |klass|
          { klass => klass.new(source_configuration_for(klass)) }
        end.reduce({}, :merge)
      end

      private

      private_attr_reader :configuration, :smell_types

      def source_configuration_for(klass)
        configuration[klass] || {}
      end

      # TODO: Make a method smell_detectors_for(scope)
      def smell_listeners
        @smell_listeners ||= Hash.new { |hash, key| hash[key] = [] }.tap do |listeners|
          detectors.each_value { |detector| detector.register(listeners) }
        end
      end
    end
  end
end
