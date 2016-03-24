require_relative '../../spec_helper'
require_lib 'reek/cli/input'

RSpec.describe Reek::CLI::Input do
  # dummy class which includes module under test
  class DummyClass
    include Reek::CLI::Input

    def argv; end

    def configuration; end
  end

  let(:path_excluded_in_configuration) do
    SAMPLES_PATH.join('source_with_exclude_paths/ignore_me/uncommunicative_method_name.rb')
  end

  let(:configuration) { test_configuration_for(SAMPLES_PATH.join('configuration/with_excluded_paths.reek')) }

  subject { DummyClass.new }

  before do
    allow(subject).to receive(:configuration).and_return(configuration)
  end

  describe '#sources' do
    context 'when no source files given' do
      before do
        allow(subject).to receive(:argv).and_return([])
      end

      context 'and input was piped' do
        before do
          allow_any_instance_of(IO).to receive(:tty?).and_return(false)
          expect(subject).to receive(:source_from_pipe).and_call_original
        end

        it 'should use source form pipe' do
          expect(subject.sources).to_not be_empty
        end
      end

      context 'and input was not piped' do
        before do
          allow_any_instance_of(IO).to receive(:tty?).and_return(true)
          expect(subject).to receive(:working_directory_as_source).
            and_call_original
        end

        it 'should use working directory as source' do
          expect(subject.sources).to_not be_empty
        end

        it 'should use configuration for excluded paths' do
          expect(subject.sources).to_not include(path_excluded_in_configuration)
        end
      end
    end

    context 'when source files given' do
      before do
        allow(subject).to receive(:argv).and_return(['.'])
        expect(subject).to receive(:sources_from_argv).and_call_original
      end

      it 'should use sources from argv' do
        expect(subject.sources).to_not be_empty
      end
    end
  end
end
