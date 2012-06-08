require 'rubygems'
require 'bundler'
Bundler.require :development, :default # Explicitly necessary here.


require File.join((File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'spec')
require File.join((File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'source', 'tree_dresser')

require File.join(File.dirname(File.expand_path(__FILE__)), 'matchers', 'smell_of_matcher')

SAMPLES_DIR = 'spec/samples' unless Object.const_defined?('SAMPLES_DIR')

def ast(*args)
  result = Reek::Source::TreeDresser.new.dress(s(*args))
  result.line = 1
  result
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  #config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  #config.filter_run :focus
end
