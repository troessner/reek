# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    # Check syntax errors.
    # Note: this detector is called by examiner directly unlike other detectors.
    class Syntax < BaseDetector
      DummyContext = Struct.new(:exp, :full_name).new(
        Struct.new('Exp', :source).new(nil),
        'This file')

      def self.contexts
        []
      end

      def self.smells_from_source(source)
        new.smells_from_source(source)
      end

      # :reek:FeatureEnvy
      def smells_from_source(source)
        source.diagnostics.map do |diagnostic|
          smell_warning(
            context: DummyContext,
            lines: [diagnostic.location.line],
            message: "has #{diagnostic.message}")
        end
      end
    end
  end
end
