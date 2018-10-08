require_relative '../../spec_helper'
require_lib 'reek/errors/config_file_error'
require_lib 'reek/configuration/excluded_paths'

RSpec.describe Reek::Configuration::ExcludedPaths do
  describe '#add' do
    let(:exclusions) { [].extend(described_class) }
    let(:paths) { ['smelly/sources'] }
    let(:expected_exclude_paths) { [Pathname('smelly/sources')] }

    it 'adds the given paths as Pathname' do
      exclusions.add(paths)
      expect(exclusions).to eq expected_exclude_paths
    end
  end
end
