require 'reek/spec'
require 'reek/source/ast_node_class_map'

require 'matchers/smell_of_matcher'
require 'factory_girl'

begin
  require 'pry'
  require 'byebug'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

FactoryGirl.find_definitions

SAMPLES_DIR = 'spec/samples'

# :reek:UncommunicativeMethodName
def s(type, *children)
  @klass_map ||= Reek::Source::AstNodeClassMap.new
  @klass_map.klass_for(type).new(type, children)
end

def ast(*args)
  s(*args)
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.include FactoryGirl::Syntax::Methods
end
