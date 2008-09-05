require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/smells'

include Reek

describe Smell, "camel case converter" do
  it "should convert camel case name" do
    Smell.convert_camel_case('LongParameterList').should == 'Long Parameter List'
  end
  
  it "should display correct name in report" do
    mchk = MethodChecker.new([], 'Class')
    smell = FeatureEnvy.new(mchk, [:lvar, :fred])
    smell.report.should match(/[#{smell.name}]/)
  end
end
