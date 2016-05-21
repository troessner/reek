require_relative '../../../spec_helper'
require_lib 'reek/cli/command/todo_list_command'
require_lib 'reek/cli/options'

RSpec.describe Reek::CLI::Command::TodoListCommand do
  describe '#execute' do
    let(:options) { Reek::CLI::Options.new [] }
    let(:configuration) { double 'configuration' }

    let(:command) do
      described_class.new(options: options,
                          sources: [],
                          configuration: configuration)
    end

    before do
      $stdout = StringIO.new
      allow(File).to receive(:write)
    end

    after(:all) do
      $stdout = STDOUT
    end

    context 'smells found' do
      before do
        smells = [FactoryGirl.build(:smell_warning)]
        allow(command).to receive(:scan_for_smells).and_return(smells)
      end

      it 'shows a proper message' do
        expected = "\n'.todo.reek' generated! You can now use this as a starting point for your configuration.\n"
        expect { command.execute }.to output(expected).to_stdout
      end

      it 'returns a success code' do
        result = command.execute
        expect(result).to eq(Reek::CLI::Options::DEFAULT_SUCCESS_EXIT_CODE)
      end

      it 'writes a todo file' do
        command.execute
        expected_yaml = { 'FeatureEnvy' => { 'exclude' => ['self'] } }.to_yaml
        expect(File).to have_received(:write).with(described_class::FILE_NAME, expected_yaml)
      end
    end

    context 'no smells found' do
      before do
        allow(command).to receive(:scan_for_smells).and_return []
      end

      it 'shows a proper message' do
        expected = "\n'.todo.reek' not generated because there were no smells found!\n"
        expect { command.execute }.to output(expected).to_stdout
      end

      it 'returns a success code' do
        result = command.execute
        expect(result).to eq Reek::CLI::Options::DEFAULT_SUCCESS_EXIT_CODE
      end

      it 'does not write a todo file' do
        command.execute
        expect(File).not_to have_received(:write)
      end
    end
  end
end
