require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'attribute')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'boolean_parameter')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'class_variable')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'control_couple')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'data_clump')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'duplication')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'feature_envy')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'irresponsible_module')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'large_class')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'long_method')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'long_parameter_list')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'long_yield_list')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'nested_iterators')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'simulated_polymorphism')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'uncommunicative_method_name')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'uncommunicative_module_name')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'uncommunicative_parameter_name')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'uncommunicative_variable_name')
require File.join( File.dirname( File.expand_path(__FILE__)), 'smells', 'utility_function')
# SMELL: Duplication -- all these should be found automagically

module Reek

  #
  # This module contains the various smell detectors.
  #
  module Smells
  end
end
