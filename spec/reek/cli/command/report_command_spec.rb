require_relative '../../../spec_helper'
require_lib 'reek/cli/command/report_command'
require_lib 'reek/cli/options'
require_lib 'reek/cli/option_interpreter'

RSpec.describe Reek::CLI::Command::ReportCommand do
  describe '#execute' do
    let(:options) { Reek::CLI::Options.new [] }
    let(:option_interpreter) { Reek::CLI::OptionInterpreter.new(options) }

    let(:reporter) { double 'reporter' }
    let(:app) { double 'app' }

    let(:command) { described_class.new option_interpreter }

    before do
      allow(option_interpreter).to receive(:reporter).and_return reporter
      allow(reporter).to receive(:show)
    end

    context 'when no smells are found' do
      before do
        allow(option_interpreter).to receive(:sources).and_return []
        allow(reporter).to receive(:smells?).and_return false
      end

      it 'returns a success code' do
        result = command.execute app
        expect(result).to eq Reek::CLI::Options::DEFAULT_SUCCESS_EXIT_CODE
      end
    end

    context 'when smells are found' do
      before do
        allow(option_interpreter).to receive(:sources).and_return []
        allow(reporter).to receive(:smells?).and_return true
      end

      it 'returns a failure code' do
        result = command.execute app
        expect(result).to eq Reek::CLI::Options::DEFAULT_FAILURE_EXIT_CODE
      end
    end
  end
end
