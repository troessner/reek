require 'reek/detector_stack'
require 'reek/smells/control_couple'
require 'reek/smells/duplication'
require 'reek/smells/feature_envy'
require 'reek/smells/large_class'
require 'reek/smells/long_method'
require 'reek/smells/long_parameter_list'
require 'reek/smells/long_yield_list'
require 'reek/smells/nested_iterators'
require 'reek/smells/uncommunicative_name'
require 'reek/smells/utility_function'
require 'reek/code_parser'
require 'yaml'

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
  class Sniffer

    # SMELL: Duplication
    # This list should be calculated by looking in the source folder.
    SMELL_CLASSES = [
      Smells::ControlCouple,
      Smells::Duplication,
      Smells::FeatureEnvy,
      Smells::LargeClass,
      Smells::LongMethod,
      Smells::LongParameterList,
      Smells::LongYieldList,
      Smells::NestedIterators,
      Smells::UncommunicativeName,
      Smells::UtilityFunction,
    ]

    def initialize(src)
      @already_checked_for_smells = false
      @typed_detectors = nil
      @detectors = Hash.new
      SMELL_CLASSES.each { |klass| @detectors[klass] = DetectorStack.new(klass.new) }
      @source = src
      src.configure(self)
    end

    def check_for_smells
      return if @already_checked_for_smells
      CodeParser.new(self).process(@source.syntax_tree)
      @already_checked_for_smells = true
    end

    def configure(klass, config)
      @detectors[klass].push(config)
    end

    def report_on(report)
      check_for_smells
      @detectors.each_value { |stack| stack.report_on(report) }
    end

    def examine(scope, type)
      listeners = smell_listeners[type]
      listeners.each {|smell| smell.examine(scope) } if listeners
    end

    def smelly?
      check_for_smells
      @detectors.each_value { |stack| return true if stack.smelly? }
      false
    end

    def num_smells
      check_for_smells
      total = 0
      @detectors.each_value { |stack| total += stack.num_smells }
      total
    end

    def desc
      # SMELL: Special Case
      # Only used in the Report tests, because they don't always create a Source.
      @source ? @source.desc : "unknown"
    end

    #
    # Checks for instances of +smell_class+, and returns +true+
    # only if one of them has a report string matching all of the +patterns+.
    #
    def has_smell?(smell_class, patterns=[])
      check_for_smells
      stack = @detectors[Reek::Smells.const_get(smell_class)]      # SMELL: Duplication of code in ConfigFile
      stack.has_smell?(patterns)
    end

    def smells_only_of?(klass, patterns)
      num_smells == 1 and has_smell?(klass, patterns)
    end

    def sniff
      self
    end

    def sniffers
      [self]
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

  class SnifferSet

    attr_reader :desc, :sniffers

    def initialize(sniffers, desc)
      @sniffers = sniffers
      @desc = desc
    end

    def smelly?
      @sniffers.any? {|sniffer| sniffer.smelly? }
    end

    #
    # Checks for instances of +smell_class+, and returns +true+
    # only if one of them has a report string matching all of the +patterns+.
    #
    def has_smell?(smell_class, patterns=[])
      @sniffers.any? {|sniffer| sniffer.has_smell?(smell_class, patterns)}
    end

    def num_smells
      total = 0
      @sniffers.each {|sniffer| total += sniffer.num_smells}
      total
    end

    def smells_only_of?(klass, patterns)
      num_smells == 1 and has_smell?(klass, patterns)
    end

    def sniff
      self
    end

  end
end
