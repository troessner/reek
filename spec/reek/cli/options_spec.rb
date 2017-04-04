require_relative '../../spec_helper'
require_lib 'reek/cli/options'

RSpec.describe Reek::CLI::Options do
  let(:options) { described_class.new }

  describe '#initialize' do
    it 'sets a valid default value for report_format' do
      expect(options.report_format).to eq :text
    end

    it 'sets a valid default value for location_format' do
      expect(options.location_format).to eq :numbers
    end

    it 'enables colors when stdout is a TTY' do
      allow($stdout).to receive_messages(tty?: true)
      expect(options.colored).to be true
    end

    it 'does not enable colors when stdout is not a TTY' do
      allow($stdout).to receive_messages(tty?: false)
      expect(options.colored).to be false
    end

    it 'enables progress when stdout is a TTY' do
      allow($stdout).to receive_messages(tty?: true)
      expect(options.progress_format).to eq :dots
    end

    it 'does not enable progress when stdout is not a TTY' do
      allow($stdout).to receive_messages(tty?: false)
      expect(options.progress_format).to eq :quiet
    end

    it 'sets force_exclusion to false by default' do
      expect(options.force_exclusion?).to be false
    end
  end

  describe 'parse' do
    it 'raises on invalid argument in ARGV' do
      options = described_class.new ['-z']
      expect { options.parse }.to raise_error(OptionParser::InvalidOption)
    end

    it 'returns self' do
      expect(options.parse).to be_a(described_class)
    end
  end
end
