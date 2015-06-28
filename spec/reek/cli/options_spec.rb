require_relative '../../spec_helper'

require_relative '../../../lib/reek/cli/options'

RSpec.describe Reek::CLI::Options do
  describe '#parse' do
    context 'with no arguments passed' do
      let(:options) { Reek::CLI::Options.new.parse }
      it 'enables colors when stdout is a TTY' do
        allow($stdout).to receive_messages(tty?: false)
        expect(options.colored).to be false
      end

      it 'does not enable colors when stdout is not a TTY' do
        allow($stdout).to receive_messages(tty?: true)
        expect(options.colored).to be true
      end

      it 'sets a valid default value for report_format' do
        expect(options.report_format).to eq :text
      end

      it 'sets a valid default value for location_format' do
        expect(options.location_format).to eq :numbers
      end
    end
  end
end
