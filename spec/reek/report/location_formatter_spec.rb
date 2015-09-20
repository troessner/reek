require_relative '../../spec_helper'
require_lib 'reek/report/formatter'

RSpec.describe 'location formatters' do
  let(:warning) { build(:smell_warning, lines: [11, 9, 250, 100]) }

  describe Reek::Report::BlankLocationFormatter do
    describe '.format' do
      it 'returns a blank String regardless of the warning' do
        expect(described_class.format(warning)).to eq('')
      end
    end
  end

  describe Reek::Report::DefaultLocationFormatter do
    describe '.format' do
      it 'returns a prefix with sorted line numbers' do
        expect(described_class.format(warning)).to eq('[9, 11, 100, 250]:')
      end
    end
  end

  describe Reek::Report::SingleLineLocationFormatter do
    describe '.format' do
      it 'returns the first line where the smell was found' do
        expect(described_class.format(warning)).to eq('dummy_file:9: ')
      end
    end
  end
end
