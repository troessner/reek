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

describe Name do
  it 'compares correctly' do
    a1 = [Name.new('conts'), Name.new('p1'), Name.new('p2'), Name.new('p3')]
    a2 = [Name.new('name'), Name.new('windowH'), Name.new('windowW')]
    (a1 & a2).should == []
  end

  it do
    [Name.new(:fred)].should include(Name.new(:fred))
  end

  it do
    set = Set.new
    set << Name.new(:fred)
    set.should include(Name.new(:fred))
  end

  it do
    fred = Name.new(:fred)
    fred.should eql(fred)
    fred.should eql(Name.new(:fred))
  end
end
