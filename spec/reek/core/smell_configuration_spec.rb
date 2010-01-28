require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'smell_configuration')

include Reek::Core

describe SmellConfiguration do
  it 'returns the default value when key not found' do
    cf = SmellConfiguration.new({})
    cf.value('fred', nil, 27).should == 27
  end
end
