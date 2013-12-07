require 'spec_helper'
require 'reek/examiner'
require 'reek/cli/report'

include Reek
include Reek::Cli

describe QuietReport, " when empty" do
  context 'empty source' do
    it 'has an empty quiet_report' do
      examiner = Examiner.new('')
      qr = QuietReport.new
      qr.add_examiner(examiner)
      qr.gather_results.should == []
    end
  end

  context 'with a couple of smells' do
    before :each do
      examiner = Examiner.new('def simple(a) a[3] end')
      rpt = QuietReport.new
      @result = rpt.add_examiner(examiner).gather_results.first
    end

    it 'has a header' do
      @result.should match('string -- 2 warnings')
    end

    it 'should mention every smell name' do
      @result.should match('[UncommunicativeParameterName]')
      @result.should match('[Feature Envy]')
    end
  end
end
