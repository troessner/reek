require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'reek/name'

include Reek

describe Name, 'resolving symbols' do
  it 'finds fq loaded class' do
    exp = [:class, :"Reek::Smells::LargeClass", nil]
    ctx = StopContext.new
    res = Name.resolve(exp[1], ctx)
    res[1].should == "LargeClass"
  end
end
