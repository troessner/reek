require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/adapters/core_extras'
require 'reek/adapters/report'
require 'reek/adapters/source'
require 'reek/smells/feature_envy'

include Reek

describe ReportSection, " when empty" do
  before(:each) do
    @rpt = ReportSection.new(''.sniff, '%m%c %w (%s)', false)
  end

  it 'has an empty quiet_report' do
    @rpt.quiet_report.should == ''
  end
end

describe ReportSection, "smell_list" do
  before(:each) do
    rpt = ReportSection.new('def simple(a) a[3] end'.sniff, false, '%m%c %w (%s)')
    @lines = rpt.smell_list.split("\n")
  end

  it 'should mention every smell name' do
    @lines.should have_at_least(2).lines
    @lines[0].should match(/[Utility Function]/)
    @lines[1].should match(/[Feature Envy]/)
  end
end

describe ReportSection, " as a SortedSet" do
  it 'should only add a smell once' do
    rpt = ReportSection.new(''.sniff, false, '%m%c %w (%s)')
    rpt << SmellWarning.new(Smells::FeatureEnvy.new, "self", 'too many!', false)
    rpt << SmellWarning.new(Smells::FeatureEnvy.new, "self", 'too many!', false)
    lines = rpt.smell_list.split("\n")
    lines.should have(1).lines
  end

  it 'should not count an identical masked smell' do
    rpt = ReportSection.new(''.sniff, false, '%m%c %w (%s)')
    # SMELL: Duplication -- the SmellWarning knows whether to call << or record_masked_smell
    rpt << SmellWarning.new(Smells::FeatureEnvy.new, "self", 'too many!', false)
    rpt.record_masked_smell(SmellWarning.new(Smells::FeatureEnvy.new, "self", 'too many!', true))
    rpt.header.should == 'string -- 1 warning'
  end
end
