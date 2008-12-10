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

class Hash
  def value_merge!(other)
    keys.each do |key|
      self[key].merge!(other[key])
    end
    self
  end
  
  def deep_copy
    YAML::load(YAML::dump(self))
  end
end

module Reek

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

  CONFIG = Hash.new {|hash,key| hash[key] = {} }
  SMELLS = Hash.new {|hash,key| hash[key] = [] }
  
  SMELL_CLASSES.each do |smell|
    smell.configure(CONFIG)
    smell.attach_to(SMELLS)
  end

end
