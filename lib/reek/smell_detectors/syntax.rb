# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    # Check syntax errors.
    # Note: this detector is called by examiner directly unlike other detectors.
    class Syntax < BaseDetector
      # Context duck type for this atypical smell detector
      DummyContext = Struct.new(:exp, :full_name)
      # Exp duck type for this atypical smell detector
      DummyExp = Struct.new(:source)

      def self.contexts
        []
      end

      def self.smells_from_source(source)
        new.smells_from_source(source)
      end

      # :reek:FeatureEnvy
      def smells_from_source(source)
        context = DummyContext.new(
          DummyExp.new(source.origin),
          'This file')
        source.diagnostics.map do |diagnostic|
          smell_warning(
            context: context,
            lines: [diagnostic.location.line],
            message: "has #{diagnostic.message}")
        end
      end
    end
  end
end
