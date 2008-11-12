require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/smells'

include Reek

describe Smell, "camel case converter" do
  it "should convert camel case name" do
    Smell.convert_camel_case('LongParameterList').should == 'Long Parameter List'
  end
  
  it "should display correct name in report" do
    smell = LongMethod.new(self, 25)
    smell.report.should match(/[#{smell.name}]/)
  end
end

describe Smell, ' in comparisons' do
  it 'should hash equal when the smell is the same' do
    UtilityFunction.new(self, 2).hash.should == UtilityFunction.new(self, 2).hash
    NestedIterators.new(self).hash.should == NestedIterators.new(self).hash
  end

  it 'should compare equal when the smell is the same' do
    UtilityFunction.new(self, 2).should == UtilityFunction.new(self, 2)
    NestedIterators.new(self).should == NestedIterators.new(self)
  end

  it 'should compare equal when using <=>' do
    (UtilityFunction.new(self, 2) <=> UtilityFunction.new(self, 2)).should == 0
    (NestedIterators.new(self) <=> NestedIterators.new(self)).should == 0
  end
end