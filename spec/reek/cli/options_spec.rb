require_relative '../../spec_helper'

require_relative '../../../lib/reek/cli/options'

RSpec.describe Reek::CLI::Options do
  describe '#initialize' do
    it 'should enable colors when stdout is a TTY' do
      allow($stdout).to receive_messages(tty?: false)
      options = Reek::CLI::Options.new.parse
      expect(options.colored).to be false
    end

    it 'should not enable colors when stdout is not a TTY' do
      allow($stdout).to receive_messages(tty?: true)
      options = Reek::CLI::Options.new.parse
      expect(options.colored).to be true
    end
  end
end
