require_relative '../../spec_helper'

require_relative '../../../lib/reek/cli/options'
require_relative '../../../lib/reek/report/report'

RSpec.describe Reek::CLI::OptionInterpreter do
  let(:options) { OpenStruct.new }
  let(:instance) { Reek::CLI::OptionInterpreter.new(options) }

  describe '#reporter' do
    it 'returns a Report::TextReport instance by default' do
      expect(instance.reporter).to be_instance_of Reek::Report::TextReport
    end
  end
end
