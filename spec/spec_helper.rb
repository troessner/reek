require 'sexp_dresser/source/core_extras'
require 'sexp_dresser/core/hash_extensions'
require 'sexp_dresser/source/tree_dresser'

def ast(*args)
  result = SexpDresser::Source::TreeDresser.new.dress(s(*args))
  result.line = 1
  result
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
