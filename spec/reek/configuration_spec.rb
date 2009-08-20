require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/configuration'

include Reek

describe SmellConfiguration do
  it 'returns the default value when key not found' do
    cf = SmellConfiguration.new({})
    cf.value('fred', nil, 27).should == 27
  end
end
