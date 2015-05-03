require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/examiner'
require_relative '../../../lib/reek/cli/report/report'
require_relative '../../../lib/reek/cli/report/formatter'
require_relative '../../../lib/reek/cli/report/heading_formatter'
require 'rainbow'

RSpec.describe Reek::CLI::Report::TextReport do
  let(:report_options) do
    {
      warning_formatter: Reek::CLI::Report::SimpleWarningFormatter.new,
      report_formatter: Reek::CLI::Report::Formatter,
      heading_formatter: Reek::CLI::Report::HeadingFormatter::Quiet
    }
  end
  let(:instance) { Reek::CLI::Report::TextReport.new report_options }

  context 'with a single empty source' do
    before do
      instance.add_examiner Reek::Core::Examiner.new('')
    end

    it 'has an empty quiet_report' do
      expect { instance.show }.to_not output.to_stdout
    end
  end

  context 'with non smelly files' do
    before do
      instance.add_examiner(Reek::Core::Examiner.new('def simple() puts "a" end'))
      instance.add_examiner(Reek::Core::Examiner.new('def simple() puts "a" end'))
    end

    context 'with colors disabled' do
      before :each do
        Rainbow.enabled = false
      end

      it 'shows total of 0 warnings' do
        expect { instance.show }.to output(/0 total warnings\n\Z/).to_stdout
      end
    end

    context 'with colors enabled' do
      before :each do
        Rainbow.enabled = true
      end

      it 'has a footer in color' do
        expect { instance.show }.to output(/\e\[32m0 total warnings\n\e\[0m\Z/).to_stdout
      end
    end
  end

  context 'with a couple of smells' do
    before do
      instance.add_examiner(Reek::Core::Examiner.new('def simple(a) a[3] end'))
      instance.add_examiner(Reek::Core::Examiner.new('def simple(a) a[3] end'))
    end

    context 'with colors disabled' do
      before do
        Rainbow.enabled = false
      end

      it 'has a heading' do
        expect { instance.show }.to output(/string -- 2 warnings/).to_stdout
      end

      it 'should mention every smell name' do
        expect { instance.show }.to output(/UncommunicativeParameterName/).to_stdout
        expect { instance.show }.to output(/UtilityFunction/).to_stdout
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

      it 'has a footer in color' do
        expect { instance.show }.
          to output(/\e\[31m4 total warnings\n\e\[0m\Z/).to_stdout
      end
    end
  end
end
