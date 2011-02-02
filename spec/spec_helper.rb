Dir["spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
end

require File.join((File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'spec')
require File.join((File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'source', 'tree_dresser')

require File.join(File.dirname(File.expand_path(__FILE__)), 'matchers', 'smell_of_matcher')

SAMPLES_DIR = 'spec/samples' unless Object.const_defined?('SAMPLES_DIR')

def ast(*args)
  result = Reek::Source::TreeDresser.new.dress(s(*args))
  result.line = 1
  result
end
