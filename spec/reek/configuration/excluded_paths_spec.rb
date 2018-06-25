require_relative '../../spec_helper'
require_lib 'reek/errors/config_file_error'
require_lib 'reek/configuration/excluded_paths'

RSpec.describe Reek::Configuration::ExcludedPaths do
  describe '#add' do
    let(:exclusions) { [].extend(described_class) }

    context 'when one of given paths is a file' do
      let(:smelly_source_dir) { SAMPLES_DIR.join('smelly_source') }
      let(:file_as_path) { smelly_source_dir.join('inline.rb') }
      let(:paths) { [smelly_source_dir, file_as_path] }

      it 'raises an error if one of the given paths is a file' do
        Reek::CLI::Silencer.silently do
          expect { exclusions.add(paths) }.to raise_error(Reek::Errors::ConfigFileError)
        end
      end
    end
  end
end
