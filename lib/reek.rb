$:.unshift File.dirname(__FILE__)

require 'reek/code_parser'
require 'reek/report'

module Reek # :doc:

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

  #
  # Analyse the given source, looking for code smells.
  # The source can be a filename or a String containing Ruby code.
  # Returns a +Report+ listing the smells found.
  #
  def self.analyse(src)  # :doc:
    report = Report.new
    config = base_config
    if File.exists?(src)
      source = IO.readlines(src).join
      dir = File.dirname(src)
      reeks = Dir["#{dir}/*.reek"]
      reeks.each do |rfile|
        cf = YAML.load_file(rfile)
        config.value_merge!(cf)
      end
    else
      source = src
    end
    smells = smell_listeners(config)
    CodeParser.new(report, smells).check_source(source)
    report
  end
  
  def self.base_config
    defaults_file = File.join(File.dirname(__FILE__), '..', 'config', 'defaults.reek')
    return YAML.load_file(defaults_file)
  end

  def self.smell_listeners(config = base_config)
    result = Hash.new {|hash,key| hash[key] = [] }
    SMELL_CLASSES.each { |smell| smell.listen(result, config) }
    return result
  end
end
