require_relative '../../spec_helper'
require_lib 'reek/configuration/excluded_paths'

RSpec.describe Reek::Configuration::ExcludedPaths do
  describe '#add' do
    subject { [].extend(described_class) }

    context 'one of the given paths does not exist' do
      let(:bogus_path) { Pathname('does/not/exist') }
      let(:paths) { [SAMPLES_PATH, bogus_path] }

      it 'raises an error' do
        Reek::CLI::Silencer.silently do
          expect { subject.add(paths) }.to raise_error(SystemExit)
        end
      end
    end

    context 'one of given paths is a file' do
      let(:file_as_path) { SAMPLES_PATH.join('inline.rb') }
      let(:paths) { [SAMPLES_PATH, file_as_path] }

      it 'raises an error if one of the given paths is a file' do
        Reek::CLI::Silencer.silently do
          expect { subject.add(paths) }.to raise_error(SystemExit)
        end
      end
    end
  end
end
