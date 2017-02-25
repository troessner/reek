require_relative '../../../spec_helper'
require_lib 'reek/cli/command/todo_list_command'
require_lib 'reek/cli/options'

RSpec.describe Reek::CLI::Command::TodoListCommand do
  let(:nil_check) { build :smell_detector, smell_type: :NilCheck }
  let(:feature_envy) { build :smell_detector, smell_type: :FeatureEnvy }
  let(:nested_iterators) { build :smell_detector, smell_type: :NestedIterators }
  let(:too_many_statements) { build :smell_detector, smell_type: :TooManyStatements }

  describe '#execute' do
    let(:options) { Reek::CLI::Options.new [] }
    let(:configuration) { instance_double 'Reek::Configuration::AppConfiguration' }

    let(:command) do
      described_class.new(options: options,
                          sources: [],
                          configuration: configuration)
    end

    before do
      $stdout = StringIO.new
      allow(File).to receive(:write)
    end

    after do
      $stdout = STDOUT
    end

    context 'smells found' do
      before do
        smells = [build(:smell_warning, context: 'Foo#bar')]
        allow(command).to receive(:scan_for_smells).and_return(smells)
      end

      it 'shows a proper message' do
        expected = "\n'.todo.reek' generated! You can now use this as a starting point for your configuration.\n"
        expect { command.execute }.to output(expected).to_stdout
      end

      it 'returns a success code' do
        result = command.execute
        expect(result).to eq(Reek::CLI::Status::DEFAULT_SUCCESS_EXIT_CODE)
      end

      it 'writes a todo file' do
        command.execute
        expected_yaml = { 'FeatureEnvy' => { 'exclude' => ['Foo#bar'] } }.to_yaml
        expect(File).to have_received(:write).with(described_class::FILE_NAME, expected_yaml)
      end
    end

    context 'smells with duplicate context found' do
      before do
        smells = [
          build(:smell_warning, context: 'Foo#bar', smell_detector: feature_envy),
          build(:smell_warning, context: 'Foo#bar', smell_detector: feature_envy)
        ]
        allow(command).to receive(:scan_for_smells).and_return(smells)
      end

      it 'writes the context into the todo file once' do
        command.execute
        expected_yaml = { 'FeatureEnvy' => { 'exclude' => ['Foo#bar'] } }.to_yaml
        expect(File).to have_received(:write).with(described_class::FILE_NAME, expected_yaml)
      end
    end

    context 'smells with default exclusions found' do
      let(:smell) { build :smell_warning, smell_detector: too_many_statements, context: 'Foo#bar' }

      before do
        allow(command).to receive(:scan_for_smells).and_return [smell]
      end

      it 'includes the default exclusions in the generated yaml' do
        command.execute
        expected_yaml = { 'TooManyStatements' => { 'exclude' => ['initialize', 'Foo#bar'] } }.to_yaml
        expect(File).to have_received(:write).with(described_class::FILE_NAME, expected_yaml)
      end
    end

    context 'smells of different types found' do
      before do
        smells = [
          build(:smell_warning, context: 'Foo#bar', smell_detector: nil_check),
          build(:smell_warning, context: 'Bar#baz', smell_detector: nested_iterators)
        ]
        allow(command).to receive(:scan_for_smells).and_return(smells)
      end

      it 'writes the context into the todo file once' do
        command.execute
        expected_yaml = {
          'NilCheck' => { 'exclude' => ['Foo#bar'] },
          'NestedIterators' => { 'exclude' => ['Bar#baz'] }
        }.to_yaml
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
        expect(result).to eq Reek::CLI::Status::DEFAULT_SUCCESS_EXIT_CODE
      end

      it 'does not write a todo file' do
        command.execute
        expect(File).not_to have_received(:write)
      end
    end
  end
end
