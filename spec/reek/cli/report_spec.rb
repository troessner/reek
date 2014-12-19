require 'spec_helper'
require 'reek/examiner'
require 'reek/cli/report/report'
require 'reek/cli/report/formatter'
require 'reek/cli/report/strategy'
require 'rainbow'
require 'stringio'

include Reek
include Reek::Cli

def capture_output_stream
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = STDOUT
end

def report_options
  {
    warning_formatter: Report::SimpleWarningFormatter,
    report_formatter: Report::Formatter,
    strategy: Report::Strategy::Quiet
  }
end

describe Report::TextReport, ' when empty' do
  context 'empty source' do
    let(:examiner) { Examiner.new('') }

    def report(obj)
      obj.add_examiner examiner
    end

    it 'has an empty quiet_report' do
      tr = Report::TextReport.new
      tr.add_examiner(examiner)
      expect { tr.show }.to_not output.to_stdout
    end

    context 'when output format is html' do
      it 'has the text 0 total warnings' do
        html_report = report(Report::HtmlReport.new(report_options))
        html_report.show

        file = File.expand_path('../../../../reek.html', __FILE__)
        text = File.read(file)
        File.delete(file)

        expect(text).to include('0 total warnings')
      end
    end

    context 'when output format is yaml' do
      it 'prints empty yaml' do
        yaml_report = report(Report::YamlReport.new(report_options))
        output = capture_output_stream { yaml_report.show }
        expect(output).to match(/^--- \[\]\n.*$/)
      end
    end

    context 'when output format is text' do
      it 'prints nothing' do
        text_report = report(Report::TextReport.new)
        expect { text_report.show }.to_not output.to_stdout
      end
    end
  end

  context 'with a couple of smells' do
    before :each do
      @examiner = Examiner.new('def simple(a) a[3] end')
      @rpt = Report::TextReport.new report_options
    end

    context 'with colors disabled' do
      before :each do
        Rainbow.enabled = false
        @result = @rpt.add_examiner(@examiner).smells.first
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
      end

      context 'with non smelly files' do
        before :each do
          Rainbow.enabled = true
          @rpt.add_examiner(Examiner.new('def simple() puts "a" end'))
          @rpt.add_examiner(Examiner.new('def simple() puts "a" end'))
          @result = @rpt.smells
        end

        it 'has a footer in color' do
          output = capture_output_stream { @rpt.show }
          expect(output).to end_with "\e[32m0 total warnings\n\e[0m"
        end
      end

      context 'with smelly files' do
        before :each do
          Rainbow.enabled = true
          @rpt.add_examiner(Examiner.new('def simple(a) a[3] end'))
          @rpt.add_examiner(Examiner.new('def simple(a) a[3] end'))
          @result = @rpt.smells
        end

        it 'has a header in color' do
          expect(@result.first).
            to start_with "\e[36mstring -- \e[0m\e[33m2 warning\e[0m\e[33ms\e[0m"
        end

        it 'has a footer in color' do
          output = capture_output_stream { @rpt.show }
          expect(output).to end_with "\e[31m4 total warnings\n\e[0m"
        end
      end
    end
  end
end
