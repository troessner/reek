#require File.dirname(__FILE__) + '/../../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'adapters', 'report')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'adapters', 'core_extras')

include Reek

describe ReportSection, " when empty" do
  before(:each) do
    @rpt = ReportSection.new(''.sniff, false)
  end

  it 'has an empty quiet_report' do
    @rpt.quiet_report.should == ''
  end
end

describe ReportSection, "smell_list" do
  before(:each) do
    rpt = ReportSection.new('def simple(a) a[3] end'.sniff, false)
    @lines = rpt.smell_list.split("\n")
  end

  it 'should mention every smell name' do
    @lines.should have_at_least(2).lines
    @lines[0].should match(/[Utility Function]/)
    @lines[1].should match(/[Feature Envy]/)
  end
end
