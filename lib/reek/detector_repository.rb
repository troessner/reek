# frozen_string_literal: true

require_relative 'smell_detectors'
require_relative 'smell_detectors/base_detector'
require_relative 'configuration/app_configuration'

module Reek
  #
  # Contains all the existing smell detectors and exposes operations on them.
  #
  class DetectorRepository
    # @return [Array<Reek::SmellDetectors::BaseDetector>] All known SmellDetectors
    #         e.g. [Reek::SmellDetectors::BooleanParameter, Reek::SmellDetectors::ClassVariable].
    def self.smell_types
      Reek::SmellDetectors::BaseDetector.descendants.sort_by(&:name)
    end

    # @param filter_by_smells [Array<String>]
    #   List of smell types to filter by, e.g. "DuplicateMethodCall".
    #   More precisely it should be whatever is returned by `BaseDetector`.smell_type.
    #   This means that you can write the "DuplicateMethodCall" from above also like this:
    #     Reek::SmellDetectors::DuplicateMethodCall.smell_type
    #   if you want to make sure you do not fat-finger strings.
    #
    # @return [Array<Reek::SmellDetectors::BaseDetector>] All SmellDetectors that we want to filter for
    #         e.g. [Reek::SmellDetectors::Attribute].
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
    end

    def examine(context)
      smell_detectors_for(context.type).flat_map do |klass|
        detector = klass.new configuration: configuration_for(klass), context: context
        detector.run
      end
    end

    private

    attr_reader :configuration, :smell_types

    def configuration_for(klass)
      configuration.fetch klass, {}
    end

    def smell_detectors_for(type)
      smell_types.select { |detector| detector.contexts.include? type }
    end
  end
end
