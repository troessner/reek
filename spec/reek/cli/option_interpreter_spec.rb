require_relative '../../spec_helper'

require_lib 'reek/cli/options'
require_lib 'reek/cli/option_interpreter'
require_lib 'reek/report/report'

RSpec.describe Reek::CLI::OptionInterpreter do
  describe '#reporter' do
    context 'with a valid set of options' do
      let(:options) do
        Reek::CLI::Options.new.parse
      end
      subject { described_class.new(options) }

      it 'returns an object of the correct subclass of Report::Base' do
        expect(subject.reporter).to be_instance_of Reek::Report::TextReport
      end
    end
  end
end
