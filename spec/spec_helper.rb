require 'reek/spec'
require 'reek/source/tree_dresser'

require 'matchers/smell_of_matcher'
begin
  require 'debugger'
rescue LoadError
  # Swallow error. Not required to run tests
end

SAMPLES_DIR = 'spec/samples'

def ast(*args)
  result = Reek::Source::TreeDresser.new.dress(s(*args))
  result.line = 1
  result
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
