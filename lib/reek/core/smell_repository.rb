require 'reek/smells'

module Reek
  module Core
    #
    # Contains all the existing smells and exposes operations on them.
    #
    class SmellRepository

      def self.smell_classes
        # SMELL: Duplication -- these should be loaded by listing the files
        [
          Smells::Attribute,
          Smells::BooleanParameter,
          Smells::ClassVariable,
          Smells::ControlParameter,
          Smells::DataClump,
          Smells::DuplicateMethodCall,
          Smells::FeatureEnvy,
          Smells::IrresponsibleModule,
          Smells::LongParameterList,
          Smells::LongYieldList,
          Smells::NestedIterators,
          Smells::NilCheck,
          Smells::PrimaDonnaMethod,
          Smells::RepeatedConditional,
          Smells::TooManyInstanceVariables,
          Smells::TooManyMethods,
          Smells::TooManyStatements,
          Smells::UncommunicativeMethodName,
          Smells::UncommunicativeModuleName,
          Smells::UncommunicativeParameterName,
          Smells::UncommunicativeVariableName,
          Smells::UnusedParameters,
          Smells::UtilityFunction
        ]
      end

      def initialize source_description, smell_classes=SmellRepository.smell_classes
        @typed_detectors = nil
        @detectors = Hash.new
        smell_classes.each do |klass|
          @detectors[klass] = klass.new(source_description)
        end
      end

      def configure(klass, config)
        @detectors[klass].configure_with(config) if @detectors[klass]
      end

      def report_on listener
        @detectors.each_value { |detector| detector.report_on(listener) }
      end

      def examine(scope, node_type)
        smell_listeners[node_type].each do |detector|
          detector.examine(scope)
        end
      end

      private

      def smell_listeners()
        unless @typed_detectors
          @typed_detectors = Hash.new {|hash,key| hash[key] = [] }
          @detectors.each_value { |detector| detector.register(@typed_detectors) }
        end
        @typed_detectors
      end
    end
  end
end
