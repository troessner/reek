require 'pathname'
require_relative '../../spec_helper'
require_lib 'reek/configuration/app_configuration'
require_lib 'reek/configuration/directory_directives'
require_lib 'reek/configuration/default_directive'
require_lib 'reek/configuration/excluded_paths'

RSpec.describe Reek::Configuration::AppConfiguration do
  describe '#new' do
    it 'raises NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe 'factory methods' do
    let(:expected_excluded_paths) do
      [SAMPLES_PATH.join('two_smelly_files'),
       SAMPLES_PATH.join('source_with_non_ruby_files')]
    end
    let(:expected_default_directive) do
      { Reek::Smells::IrresponsibleModule => { 'enabled' => false } }
    end
    let(:expected_directory_directives) do
      { Pathname.new('spec/samples/three_clean_files') =>
        { Reek::Smells::UtilityFunction => { 'enabled' => false } } }
    end

    let(:default_directive_value) do
      { 'IrresponsibleModule' => { 'enabled' => false } }
    end

    let(:directory_directives_value) do
      { 'spec/samples/three_clean_files' =>
        { 'UtilityFunction' => { 'enabled' => false } } }
    end

    let(:exclude_paths_value) do
      ['spec/samples/two_smelly_files',
       'spec/samples/source_with_non_ruby_files']
    end

    let(:combined_value) do
      directory_directives_value.
        merge(default_directive_value).
        merge('exclude_paths' => exclude_paths_value)
    end

    describe '#from_path' do
      let(:full_configuration_path) { SAMPLES_PATH.join('configuration/full_configuration.reek') }

      it 'properly loads configuration and processes it' do
        config = described_class.from_path full_configuration_path

        expect(config.send(:excluded_paths)).to eq(expected_excluded_paths)
        expect(config.send(:default_directive)).to eq(expected_default_directive)
        expect(config.send(:directory_directives)).to eq(expected_directory_directives)
      end
    end

    describe '#from_map' do
      it 'properly sets the configuration from simple data structures' do
        config = described_class.from_map(directory_directives: directory_directives_value,
                                          default_directive: default_directive_value,
                                          excluded_paths: exclude_paths_value)

        expect(config.send(:excluded_paths)).to eq(expected_excluded_paths)
        expect(config.send(:default_directive)).to eq(expected_default_directive)
        expect(config.send(:directory_directives)).to eq(expected_directory_directives)
      end

      it 'properly sets the configuration from native structures' do
        config = described_class.from_map(directory_directives: expected_directory_directives,
                                          default_directive: expected_default_directive,
                                          excluded_paths: expected_excluded_paths)

        expect(config.send(:excluded_paths)).to eq(expected_excluded_paths)
        expect(config.send(:default_directive)).to eq(expected_default_directive)
        expect(config.send(:directory_directives)).to eq(expected_directory_directives)
      end
    end

    describe '#from_hash' do
      it 'sets the configuration a unified simple data structure' do
        config = described_class.from_hash(combined_value)

        expect(config.send(:excluded_paths)).to eq(expected_excluded_paths)
        expect(config.send(:default_directive)).to eq(expected_default_directive)
        expect(config.send(:directory_directives)).to eq(expected_directory_directives)
      end
    end
  end

  describe '#directive_for' do
    let(:source_via) { 'spec/samples/three_clean_files/dummy.rb' }

    context 'our source is in a directory for which we have a directive' do
      let(:baz_config)  { { Reek::Smells::IrresponsibleModule => { enabled: false } } }
      let(:bang_config) { { Reek::Smells::Attribute => { enabled: true } } }

      let(:directory_directives) do
        {
          'spec/samples/two_smelly_files' => baz_config,
          'spec/samples/three_clean_files' => bang_config
        }
      end

      it 'returns the corresponding directive' do
        configuration = described_class.from_map directory_directives: directory_directives
        expect(configuration.directive_for(source_via)).to eq(bang_config)
      end
    end

    context 'our source is not in a directory for which we have a directive' do
      let(:default_directive) { { Reek::Smells::IrresponsibleModule => { enabled: false } } }
      let(:attribute_config) { { Reek::Smells::Attribute => { enabled: false } } }
      let(:directory_directives) do
        { 'spec/samples/two_smelly_files' => attribute_config }
      end

      it 'returns the default directive' do
        configuration = described_class.from_map directory_directives: directory_directives,
                                                 default_directive: default_directive
        expect(configuration.directive_for(source_via)).to eq(default_directive)
      end
    end
  end
end
