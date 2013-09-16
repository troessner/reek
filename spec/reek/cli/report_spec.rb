require 'spec_helper'
require 'reek/examiner'
require 'reek/cli/report'

include Reek
include Reek::Cli

describe QuietReport, " when empty" do
  context 'empty source' do
    it 'has an empty quiet_report' do
      examiner = Examiner.new('')
      QuietReport.new.report(examiner).should == ''
    end
  end

  context 'with a couple of smells' do
    before :each do
      examiner = Examiner.new('def simple(a) a[3] end')
      rpt = QuietReport.new
      @lines = rpt.report(examiner).split("\n")
    end
    it 'has a header and a list of smells' do
      @lines.should have_at_least(3).lines
    end
    it 'should mention every smell name' do
      @lines[0].should match('[Utility Function]')
      @lines[1].should match('[Feature Envy]')
    end
  end
end
