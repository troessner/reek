require File.dirname(__FILE__) + '/../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'configuration')

include Reek

describe SmellConfiguration do
  it 'returns the default value when key not found' do
    cf = SmellConfiguration.new({})
    cf.value('fred', nil, 27).should == 27
  end
end
