require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/smells'

include Reek

describe SmellReport, "camel case converter" do
  it "should convert camel case name" do
    LongParameterListReport.smell_name.should == 'Long Parameter List'
  end
  
  it "should display correct name in report" do
    smell = LongMethodReport.new(self, 25)
    smell.report.should match(/[#{smell.class.smell_name}]/)
  end
end

describe SmellReport, ' in comparisons' do
  it 'should hash equal when the smell is the same' do
    UtilityFunctionReport.new(self).hash.should == UtilityFunctionReport.new(self).hash
    NestedIteratorsReport.new(self).hash.should == NestedIteratorsReport.new(self).hash
  end

  it 'should compare equal when the smell is the same' do
    UtilityFunctionReport.new(self).should == UtilityFunctionReport.new(self)
    NestedIteratorsReport.new(self).should == NestedIteratorsReport.new(self)
  end

  it 'should compare equal when using <=>' do
    (UtilityFunctionReport.new(self) <=> UtilityFunctionReport.new(self)).should == 0
    (NestedIteratorsReport.new(self) <=> NestedIteratorsReport.new(self)).should == 0
  end
end