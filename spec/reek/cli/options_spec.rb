require_relative '../../spec_helper'
require_lib 'reek/cli/options'

RSpec.describe Reek::CLI::Options do
  describe '#initialize' do
    it 'sets a valid default value for report_format' do
      expect(subject.report_format).to eq :text
    end

    it 'sets a valid default value for location_format' do
      expect(subject.location_format).to eq :numbers
    end

    it 'enables colors when stdout is a TTY' do
      allow($stdout).to receive_messages(tty?: false)
      expect(subject.colored).to be false
    end

    it 'does not enable colors when stdout is not a TTY' do
      allow($stdout).to receive_messages(tty?: true)
      expect(subject.colored).to be true
    end
  end

  describe 'parse' do
    it 'raises on invalid argument in ARGV' do
      options = described_class.new ['-z']
      expect { options.parse }.to raise_error(OptionParser::InvalidOption)
    end

    it 'returns self' do
      expect(subject.parse).to be_a(described_class)
    end
  end
end
