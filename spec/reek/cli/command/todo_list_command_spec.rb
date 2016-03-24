require_relative '../../../spec_helper'
require_lib 'reek/cli/command/todo_list_command'
require_lib 'reek/cli/options'
require_lib 'reek/cli/option_interpreter'

RSpec.describe Reek::CLI::Command::TodoListCommand do
  describe '#execute' do
    let(:option_interpreter) { FactoryGirl.build(:options_interpreter_with_empty_sources) }
    let(:app) { double 'app' }
    let(:command) { described_class.new(option_interpreter, sources: []) }

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
        expect { command.execute app }.to output(expected).to_stdout
      end

      it 'returns a success code' do
        result = command.execute app
        expect(result).to eq(Reek::CLI::Options::DEFAULT_SUCCESS_EXIT_CODE)
      end
    end

    context 'no smells found' do
      before do
        allow(command).to receive(:scan_for_smells).and_return []
      end

      it 'shows a proper message' do
        expected = "\n'.todo.reek' not generated because there were no smells found!\n"
        expect { command.execute app }.to output(expected).to_stdout
      end

      it 'returns a success code' do
        result = command.execute app
        expect(result).to eq Reek::CLI::Options::DEFAULT_SUCCESS_EXIT_CODE
      end
    end

    describe 'groups_for' do
      let(:command) { described_class.new({}, sources: []) }

      it 'returns a proper hash representation of the smells found' do
        smells = [FactoryGirl.build(:smell_warning)]
        expected = { 'FeatureEnvy' => { 'exclude' => ['self'] } }
        expect(command.send(:groups_for, smells)).to eq(expected)
      end
    end
  end
end
