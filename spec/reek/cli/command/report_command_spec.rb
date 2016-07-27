require_relative '../../../spec_helper'
require_lib 'reek/cli/command/report_command'
require_lib 'reek/cli/options'

RSpec.describe Reek::CLI::Command::ReportCommand do
  describe '#execute' do
    let(:options) { Reek::CLI::Options.new [] }

    let(:reporter) { double 'reporter' }
    let(:configuration) { double 'configuration' }
    let(:sources) { [source_file] }

    let(:command) do
      described_class.new(options: options,
                          sources: sources,
                          configuration: configuration)
    end

    before do
      allow(configuration).to receive(:directive_for).and_return({})
    end

    context 'when no smells are found' do
      let(:source_file) { CLEAN_FILE }

      it 'returns a success code' do
        result = command.execute
        expect(result).to eq Reek::CLI::Options::DEFAULT_SUCCESS_EXIT_CODE
      end
    end

    context 'when smells are found' do
      let(:source_file) { SMELLY_FILE }

      it 'returns a failure code' do
        result = Reek::CLI::Silencer.silently do
          command.execute
        end
        expect(result).to eq Reek::CLI::Options::DEFAULT_FAILURE_EXIT_CODE
      end
    end
  end
end
