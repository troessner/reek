require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'examiner')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'cli')

include Reek
include Reek::Cli

describe ReportSection, " when empty" do
  context 'empty source' do
    it 'has an empty quiet_report' do
      examiner = Examiner.new('')
      ReportSection.new(examiner, false).quiet_report.should == ''
    end
  end

  context 'with a couple of smells' do
    it 'should mention every smell name' do
      examiner = Examiner.new('def simple(a) a[3] end')
      rpt = ReportSection.new(examiner, false)
      @lines = rpt.smell_list.split("\n")
      @lines.should have_at_least(2).lines
      @lines[0].should match('[Utility Function]')
      @lines[1].should match('[Feature Envy]')
    end
  end
end
