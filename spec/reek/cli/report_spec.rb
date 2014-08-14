require 'spec_helper'
require 'reek/examiner'
require 'reek/cli/report'
require 'rainbow'
require 'stringio'

include Reek
include Reek::Cli

describe QuietReport, " when empty" do
  context 'empty source' do
    it 'has an empty quiet_report' do
      examiner = Examiner.new('')
      qr = QuietReport.new
      qr.add_examiner(examiner)
      expect(qr.gather_results).to eq([])
    end
  end

  context 'with a couple of smells' do
    before :each do
      @examiner = Examiner.new('def simple(a) a[3] end')
      @rpt = QuietReport.new(SimpleWarningFormatter, ReportFormatter, false, :text)
    end

    context 'with colors disabled' do
      before :each do
        Rainbow.enabled = false
        @result = @rpt.add_examiner(@examiner).gather_results.first
      end

      it 'has a header' do
        expect(@result).to match('string -- 2 warnings')
      end

      it 'should mention every smell name' do
        expect(@result).to include('UncommunicativeParameterName')
        expect(@result).to include('FeatureEnvy')
      end
    end

    context 'with colors enabled' do
      before :each do
        Rainbow.enabled = true
        @rpt.add_examiner(Examiner.new('def simple(a) a[3] end'))
        @rpt.add_examiner(Examiner.new('def simple(a) a[3] end'))
        @result = @rpt.gather_results
      end

      it 'has a header in color' do
        expect(@result.first).to start_with "\e[36mstring -- \e[0m\e[33m2 warning\e[0m\e[33ms\e[0m"
      end

      it 'has a footer in color' do
        stdout = StringIO.new
        $stdout = stdout
        @rpt.show
        $stdout = STDOUT

        expect(stdout.string).to end_with "\e[31m4 total warnings\n\e[0m"
      end
    end
  end
end
