require_relative '../../spec_helper'
require_lib 'reek/examiner'
require_lib 'reek/report/text_report'
require_lib 'reek/report/formatter'
require 'rainbow'

RSpec.describe Reek::Report::TextReport do
  let(:report_options) do
    {
      warning_formatter: Reek::Report::Formatter::SimpleWarningFormatter.new,
      report_formatter: Reek::Report::Formatter,
      heading_formatter: Reek::Report::Formatter::QuietHeadingFormatter
    }
  end
  let(:instance) { described_class.new report_options }

  context 'with a single empty source' do
    before do
      instance.add_examiner Reek::Examiner.new('')
    end

    it 'has an empty quiet_report' do
      expect { instance.show }.not_to output.to_stdout
    end
  end

  context 'with non smelly files' do
    before do
      instance.add_examiner(Reek::Examiner.new('def simple() puts "a" end'))
      instance.add_examiner(Reek::Examiner.new('def simple() puts "a" end'))
    end

    context 'with colors disabled' do
      before do
        Rainbow.enabled = false
      end

      it 'shows total of 0 warnings' do
        expect { instance.show }.to output(/0 total warnings\n\Z/).to_stdout
      end
    end

    context 'with colors enabled' do
      before do
        Rainbow.enabled = true
      end

      it 'has a footer in color' do
        expect { instance.show }.to output(/\e\[32m0 total warnings\n\e\[0m\Z/).to_stdout
      end
    end
  end

  context 'with a couple of smells' do
    before do
      instance.add_examiner(Reek::Examiner.new('def simple(a) a[3] end'))
      instance.add_examiner(Reek::Examiner.new('def simple(a) a[3] end'))
    end

    context 'with colors disabled' do
      before do
        Rainbow.enabled = false
      end

      it 'has a heading' do
        expect { instance.show }.to output(/string -- 2 warnings/).to_stdout
      end

      it 'mentions every smell name' do
        matcher = match(/UncommunicativeParameterName/).and match(/UtilityFunction/)
        expect { instance.show }.to output(matcher).to_stdout
      end

      it 'shows total number of warnings' do
        expect { instance.show }.to output(/4 total warnings\n\Z/).to_stdout
      end
    end

    context 'with colors enabled' do
      before do
        Rainbow.enabled = true
      end

      it 'has a header in color' do
        expect { instance.show }.
          to output(/\A\e\[36mstring -- \e\[0m\e\[33m2 warning\e\[0m\e\[33ms\e\[0m/).to_stdout
      end

      it 'shows total number of warnings in color' do
        expect { instance.show }.
          to output(/\e\[31m4 total warnings\n\e\[0m\Z/).to_stdout
      end
    end
  end
end
