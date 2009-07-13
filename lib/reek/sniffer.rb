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
require 'reek/config_file'
require 'reek/code_parser'
require 'reek/report'
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

    attr_accessor :source

    def initialize
      @typed_detectors = nil
      @detectors = Hash.new
      SMELL_CLASSES.each { |klass| @detectors[klass] = DetectorStack.new(klass.new) }
    end

    #
    # Configures this sniffer using any *.reek config files found
    # on the path to the named file. Config files are applied in order,
    # "root-first", so that config files closer to the named file override
    # those further up the path.
    #
    def configure_along_path(filename)
      path = File.expand_path(File.dirname(filename))
      all_reekfiles(path).each { |config_file| ConfigFile.new(config_file).configure(self) }
      self
    end

    def configure(klass, config)
      @detectors[klass].push(config)
    end

    def disable(klass)
      disabled_config = {Reek::Smells::SmellDetector::ENABLED_KEY => false}
      @detectors[klass].push(disabled_config)
    end

    def report_on(report)
      @detectors.each_value { |stack| stack.report_on(report) }
    end

    def examine(scope, type)
      listeners = smell_listeners[type]
      listeners.each {|smell| smell.examine(scope) } if listeners
    end

    #
    # Returns a +Report+ listing the smells found in this source. The first
    # call to +report+ parses the source code and constructs a list of
    # +SmellWarning+s found; subsequent calls simply return this same list.
    #
    def report
      unless @report
        CodeParser.new(self).process(@source.generate_syntax_tree)
        @report = Report.new(self)
      end
      @report
    end

    def smelly?
      report.length > 0
    end

    def quiet_report
      report.quiet_report
    end

    # SMELL: Shotgun Surgery
    # This and the above method will need to be replicated for every new
    # kind of report.
    def full_report
      report.full_report
    end

    def num_smells
      report.length
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
      report.has_smell?(smell_class, patterns)
    end

    def smells_only_of?(klass, patterns)
      report.length == 1 and has_smell?(klass, patterns)
    end

    def sniff
      self
    end

private

    def smell_listeners()
      unless @typed_detectors
        @typed_detectors = Hash.new {|hash,key| hash[key] = [] }
        @detectors.each_value { |stack| stack.listen_to(@typed_detectors) }
      end
      @typed_detectors
    end

    def all_reekfiles(path)
      return [] unless File.exist?(path)
      parent = File.dirname(path)
      return [] if path == parent
      all_reekfiles(parent) + Dir["#{path}/*.reek"]
    end
  end

  class SnifferSet

    attr_reader :sniffers, :desc

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

    def smells_only_of?(klass, patterns)
      ReportList.new(@sniffers).length == 1 and has_smell?(klass, patterns)
    end

    def quiet_report
      ReportList.new(@sniffers).quiet_report
    end


    # SMELL: Shotgun Surgery
    # This and the above method will need to be replicated for every new
    # kind of report.
    def full_report
      ReportList.new(@sniffers).full_report
    end
  end
end
