require_relative '../../spec_helper'

require_relative '../../../lib/reek/cli/options'
require_relative '../../../lib/reek/report/report'

RSpec.describe Reek::CLI::OptionInterpreter do
  describe '#reporter' do
    let(:instance) { Reek::CLI::OptionInterpreter.new(options) }

    context 'with a valid set of options' do
      let(:options) do
        OpenStruct.new(report_format: :text,
                       location_format: :plain)
      end
      it 'returns an object of the correct subclass of Report::Base' do
        expect(instance.reporter).to be_instance_of Reek::Report::TextReport
      end
    end
  end
end
