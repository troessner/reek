require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/smells'

include Reek

describe SmellDetector, "camel case converter" do
  it "should convert camel case name" do
    SmellDetector.convert_camel_case('LongParameterList').should == 'Long Parameter List'
  end
  
  it "should display correct name in report" do
    smell = LongMethodReport.new(self, 25)
    smell.report.should match(/[#{smell.name}]/)
  end
end

describe SmellDetector, ' in comparisons' do
  it 'should hash equal when the smell is the same' do
    UtilityFunctionReport.new(self, 2).hash.should == UtilityFunctionReport.new(self, 2).hash
    NestedIteratorsReport.new(self).hash.should == NestedIteratorsReport.new(self).hash
  end

  it 'should compare equal when the smell is the same' do
    UtilityFunctionReport.new(self, 2).should == UtilityFunctionReport.new(self, 2)
    NestedIteratorsReport.new(self).should == NestedIteratorsReport.new(self)
  end

  it 'should compare equal when using <=>' do
    (UtilityFunctionReport.new(self, 2) <=> UtilityFunctionReport.new(self, 2)).should == 0
    (NestedIteratorsReport.new(self) <=> NestedIteratorsReport.new(self)).should == 0
  end
end