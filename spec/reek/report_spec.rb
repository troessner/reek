require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/smells/smell_detector'
require 'reek/report'
require 'reek/source'
require 'reek/smells/feature_envy'

include Reek

describe Report, " when empty" do
  before(:each) do
    @rpt = Report.new
  end

  it 'should have zero length' do
    @rpt.length.should == 0
  end

  it 'should claim to be empty' do
    @rpt.should be_empty
  end
end

describe Report, "to_s" do
  before(:each) do
    rpt = Source.from_s('def simple(a) a[3] end').report
    @report = rpt.to_s.split("\n")
  end

  it 'should place each detailed report on a separate line' do
    @report.should have_at_least(2).lines
  end

  it 'should mention every smell name' do
    @report[0].should match(/[Utility Function]/)
    @report[1].should match(/[Feature Envy]/)
  end
end

describe Report, " as a SortedSet" do
  it 'should only add a smell once' do
    rpt = Report.new
    rpt << SmellWarning.new(Smells::FeatureEnvy.new, "self", 'too many!')
    rpt.length.should == 1
    rpt << SmellWarning.new(Smells::FeatureEnvy.new, "self", 'too many!')
    rpt.length.should == 1
  end
end
