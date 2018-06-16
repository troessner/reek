# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    # Check syntax errors.
    # Note: this detector is called by examiner directly unlike other detectors.
    class Syntax < BaseDetector
      # Exp duck type for this atypical smell detector
      DummyExp = Struct.new(:source)

      # Special context representing a whole source file or string
      class SourceContext
        def initialize(source)
          @source = source
        end

        def exp
          @exp ||= DummyExp.new(source.origin)
        end

        def full_name
          'This file'
        end

        attr_reader :source
      end

      def self.contexts
        []
      end

      def self.smells_from_source(source)
        context = SourceContext.new(source)
        new(context: context).sniff
      end

      def sniff
        diagnostics.map do |diagnostic|
          smell_warning(
            lines: [diagnostic.location.line],
            message: "has #{diagnostic.message}")
        end
      end

      private

      def diagnostics
        source.diagnostics
      end

      def source
        context.source
      end
    end
  end
end
