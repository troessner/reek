require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/smells/smells'

include Reek

describe SmellWarning, 'equality' do
  before :each do
    @first = SmellWarning.new(Smells::FeatureEnvy.new, "self", "self")
    @second = SmellWarning.new(Smells::FeatureEnvy.new, "self", "self")
    @masked = SmellWarning.new(Smells::FeatureEnvy.new, "self", "self", true)
  end

  it 'should hash equal when the smell is the same' do
    @first.hash.should == @second.hash
    @first.hash.should == @masked.hash
  end

  it 'should compare equal when the smell is the same' do
    @first.should == @second
    @first.should == @masked
  end

  it 'should compare equal when using <=>' do
    (@first <=> @second).should == 0
  end

  it 'should compare equal to masked smell' do
    (@first <=> @masked).should == 0
  end
end

describe SmellWarning, 'ordering' do
  before :each do
    @first = SmellWarning.new(Smells::FeatureEnvy.new, "aaa", "bbb")
    @second = SmellWarning.new(Smells::FeatureEnvy.new, "ccc", "ddd")
    @masked = SmellWarning.new(Smells::FeatureEnvy.new, "ccc", "ddd", true)
  end

  it 'should ignore masking in comparisons' do
    (@first <=> @second).should == (@first <=> @masked)
    (@second <=> @first).should == (@masked <=> @first)
  end
end
