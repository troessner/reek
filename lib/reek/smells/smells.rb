$:.unshift File.dirname(__FILE__)

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
require 'yaml'

class Hash
  def value_merge!(other)
    other.keys.each do |key|
      self[key].merge!(other[key])
    end
    self
  end
  
  def deep_copy
    YAML::load(YAML::dump(self))
  end
end

module Reek
  class SmellConfig

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

    def initialize
      defaults_file = File.join(File.dirname(__FILE__), '..', '..', '..', 'config', 'defaults.reek')
      @config = YAML.load_file(defaults_file)
    end

    def smell_listeners()
      result = Hash.new {|hash,key| hash[key] = [] }
      SMELL_CLASSES.each { |smell| smell.listen(result, @config) }
      return result
    end
    
    def load_local(file)
      dir = File.dirname(file)
      reeks = Dir["#{dir}/*.reek"]
      reeks.each do |rfile|
        cf = YAML.load_file(rfile)
        @config.value_merge!(cf)
      end
    end
  end
end
