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
