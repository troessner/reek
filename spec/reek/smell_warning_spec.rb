require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/smells'

include Reek

describe SmellWarning, ' in comparisons' do
  before :each do
    @first = SmellWarning.new(Smells::FeatureEnvy.new, "self", "self")
    @second = SmellWarning.new(Smells::FeatureEnvy.new, "self", "self")
  end

  it 'should hash equal when the smell is the same' do
    @first.hash.should == @second.hash
  end

  it 'should compare equal when the smell is the same' do
    @first.should == @second
  end

  it 'should compare equal when using <=>' do
    (@first <=> @second).should == 0
  end
end
