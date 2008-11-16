$:.unshift File.dirname(__FILE__)

require 'reek/smells/control_couple'
require 'reek/smells/duplication'
require 'reek/smells/feature_envy'
require 'reek/smells/long_method'
require 'reek/smells/long_parameter_list'
require 'reek/smells/long_yield_list'
require 'reek/smells/nested_iterators'
require 'reek/smells/uncommunicative_name'
require 'reek/smells/utility_function'

module Reek
  
  SMELLS = {
    :defn => [
      Smells::UncommunicativeName,
      Smells::LongMethod,
      Smells::Duplication,
      Smells::UtilityFunction,
      Smells::FeatureEnvy
      ]
  }
end
