# frozen_string_literal: true
require_relative '../smells'
require_relative 'smell_detector'
require_relative '../configuration/app_configuration'

module Reek
  module Smells
    #
    # Contains all the existing smells and exposes operations on them.
    #
    class SmellRepository
      # @return [Array<Reek::Smells::SmellDetector>] All known SmellDetectors
      #         e.g. [Reek::Smells::BooleanParameter, Reek::Smells::ClassVariable].
      def self.smell_types
        Reek::Smells::SmellDetector.descendants.sort_by(&:name)
      end

      # @param filter_by_smells [Array<String>]
      #   List of smell types to filter by, e.g. "DuplicateMethodCall".
      #   More precisely it should be whatever is returned by `SmellDetector`.smell_type.
      #   This means that you can write the "DuplicateMethodCall" from above also like this:
      #     Reek::Smells::DuplicateMethodCall.smell_type
      #   if you want to make sure you do not fat-finger strings.
      #
      # @return [Array<Reek::Smells::SmellDetector>] All SmellDetectors that we want to filter for
      #         e.g. [Reek::Smells::Attribute].
      def self.eligible_smell_types(filter_by_smells = [])
        return smell_types if filter_by_smells.empty?
        smell_types.select do |klass|
          filter_by_smells.include? klass.smell_type
        end
      end

      # Select detectors of one particular type or category.
      #
      # @param smell_type_or_category [String] smell type or category to select
      # @return [Array<Reek::Smells::SmellDetector>] the selected detectors
      def self.smell_detectors_by_type_or_category(smell_type_or_category)
        smell_types.select do |klass|
          [klass.smell_category, klass.smell_type].include? smell_type_or_category
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

      attr_reader :configuration, :smell_types, :detectors

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
