require_relative '../../spec_helper'
require_lib 'reek/errors/config_file_error'
require_lib 'reek/configuration/excluded_paths'

RSpec.describe Reek::Configuration::ExcludedPaths do
  describe '#add' do
    let(:exclusions) { [].extend(described_class) }
    let(:paths) do
      %w(samples/directory_does_not_exist/
         samples/source_with_non_ruby_files/
         samples/**/ignore_me*)
    end

    let(:expected_exclude_paths) do
      [Pathname('samples/source_with_non_ruby_files/'),
       Pathname('samples/source_with_exclude_paths/ignore_me'),
       Pathname('samples/source_with_exclude_paths/nested/ignore_me_as_well')]
    end

    it 'adds the given paths as Pathname' do
      exclusions.add(paths)
      expect(exclusions).to match_array expected_exclude_paths
    end
  end
end
