require File.join(File.dirname(File.expand_path(__FILE__)), 'detector_stack')
require File.join(File.dirname(File.expand_path(__FILE__)), 'code_parser')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smells')
require 'yaml'

#
# Extensions to +Hash+ needed by Reek.
#
class Hash
  def push_keys(hash)
    keys.each {|key| hash[key].adopt!(self[key]) }
  end

  def adopt!(other)
    other.keys.each do |key|
      ov = other[key]
      if Array === ov and has_key?(key)
        self[key] += ov
      else
        self[key] = ov
      end
    end
    self
  end
  
  def adopt(other)
    self.deep_copy.adopt!(other)
  end
  
  def deep_copy
    YAML::load(YAML::dump(self))
  end
end

module Reek
  module Core

    #
    # Configures all available smell detectors and applies them to a source.
    #
    class Sniffer

      def self.smell_classes
        # SMELL: Duplication -- these should be loaded by listing the files
        [
          Smells::Attribute,
          Smells::BooleanParameter,
          Smells::ClassVariable,
          Smells::ControlCouple,
          Smells::DataClump,
          Smells::Duplication,
          Smells::FeatureEnvy,
          Smells::IrresponsibleModule,
          Smells::LargeClass,
          Smells::LongMethod,
          Smells::LongParameterList,
          Smells::LongYieldList,
          Smells::NestedIterators,
          Smells::SimulatedPolymorphism,
          Smells::UncommunicativeMethodName,
          Smells::UncommunicativeModuleName,
          Smells::UncommunicativeParameterName,
          Smells::UncommunicativeVariableName,
          Smells::UtilityFunction,
        ]
      end

      def initialize(src)
        @already_checked_for_smells = false
        @typed_detectors = nil
        @detectors = Hash.new
        Sniffer.smell_classes.each do |klass|
          @detectors[klass] = DetectorStack.new(klass.new(src.desc))
        end
        @source = src
        src.configure(self)
      end

      def check_for_smells
        return if @already_checked_for_smells
        CodeParser.new(self).process(@source.syntax_tree)
        @already_checked_for_smells = true
      end

      def configure(klass, config)
        @detectors[klass].adopt(config)
      end

      def report_on(report)
        check_for_smells
        @detectors.each_value { |stack| stack.report_on(report) }
      end

      def examine(scope, type)
        listeners = smell_listeners[type]
        listeners.each {|smell| smell.examine(scope) } if listeners
      end

  private

      def smell_listeners()
        unless @typed_detectors
          @typed_detectors = Hash.new {|hash,key| hash[key] = [] }
          @detectors.each_value { |stack| stack.listen_to(@typed_detectors) }
        end
        @typed_detectors
      end
    end
  end
end
