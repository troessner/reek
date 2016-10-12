require_relative '../../../spec_helper'
require_lib 'reek/report/formatter/progress_formatter'

RSpec.describe Reek::Report::Formatter::ProgressFormatter::Dots do
  let(:sources_count) { 23 }
  let(:formatter) { described_class.new(sources_count) }

  describe '#header' do
    it 'announces the number of files to be inspected' do
      expect(formatter.header).to eq "Inspecting 23 file(s):\n"
    end
  end

  describe '#progress' do
    let(:clean_examiner) { instance_double(Reek::Examiner, smelly?: false) }
    let(:smelly_examiner) { instance_double(Reek::Examiner, smelly?: true) }

    context 'with colors disabled' do
      before do
        Rainbow.enabled = false
      end

      it 'returns a dot for clean files' do
        expect(formatter.progress(clean_examiner)).to eq '.'
      end

      it 'returns an S for smelly files' do
        expect(formatter.progress(smelly_examiner)).to eq 'S'
      end
    end
  end

  describe '#footer' do
    it 'returns some blank lines to offset the output' do
      expect(formatter.footer).to eq "\n\n"
    end
  end
end

RSpec.describe Reek::Report::Formatter::ProgressFormatter::Quiet do
  let(:sources_count) { 23 }
  let(:formatter) { described_class.new(sources_count) }

  describe '#header' do
    it 'is quiet' do
      expect(formatter.header).to eq ''
    end
  end

  describe '#progress' do
    let(:clean_examiner) { instance_double(Reek::Examiner, smelly?: false) }
    let(:smelly_examiner) { instance_double(Reek::Examiner, smelly?: true) }

    it 'is quiet for clean files' do
      expect(formatter.progress(clean_examiner)).to eq ''
    end

    it 'is quiet for smelly files' do
      expect(formatter.progress(smelly_examiner)).to eq ''
    end
  end

  describe '#footer' do
    it 'is quiet' do
      expect(formatter.footer).to eq ''
    end
  end
end
