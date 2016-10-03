require 'pathname'
require_relative '../../spec_helper'
require_lib 'reek/configuration/app_configuration'
require_lib 'reek/configuration/directory_directives'
require_lib 'reek/configuration/default_directive'
require_lib 'reek/configuration/excluded_paths'

RSpec.describe Reek::Configuration::AppConfiguration do
  describe 'factory methods' do
    let(:expected_excluded_paths) do
      [SAMPLES_PATH.join('two_smelly_files'),
       SAMPLES_PATH.join('source_with_non_ruby_files')]
    end

    let(:expected_default_directive) do
      { Reek::SmellDetectors::IrresponsibleModule => { 'enabled' => false } }
    end

    let(:expected_directory_directives) do
      { SAMPLES_PATH.join('three_clean_files') =>
        { Reek::SmellDetectors::UtilityFunction => { 'enabled' => false } } }
    end

    let(:default_directive_value) do
      { 'IrresponsibleModule' => { 'enabled' => false } }
    end

    let(:directory_directives_value) do
      { 'samples/three_clean_files' =>
        { 'UtilityFunction' => { 'enabled' => false } } }
    end

    let(:exclude_paths_value) do
      ['samples/two_smelly_files',
       'samples/source_with_non_ruby_files']
    end

    let(:combined_value) do
      directory_directives_value.
        merge(default_directive_value).
        merge('exclude_paths' => exclude_paths_value)
    end

    describe '#from_path' do
      let(:full_configuration_path) { CONFIG_PATH.join('full_configuration.reek') }

      it 'properly loads configuration and processes it' do
        config = described_class.from_path full_configuration_path

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

  describe '#default' do
    it 'returns a blank AppConfiguration' do
      config = described_class.default
      expect(config).to be_instance_of described_class
      expect(config.send(:excluded_paths)).to eq([])
      expect(config.send(:default_directive)).to eq({})
      expect(config.send(:directory_directives)).to eq({})
    end
  end

  describe '#directive_for' do
    context 'multiple directory directives and no default directive present' do
      let(:source_via) { 'samples/three_clean_files/dummy.rb' }
      let(:baz_config)  { { Reek::SmellDetectors::IrresponsibleModule => { enabled: false } } }
      let(:bang_config) { { Reek::SmellDetectors::Attribute => { enabled: true } } }

      let(:directory_directives) do
        {
          'samples/two_smelly_files' => baz_config,
          'samples/three_clean_files' => bang_config
        }
      end

      it 'returns the corresponding directive' do
        configuration = described_class.from_hash directory_directives
        expect(configuration.directive_for(source_via)).to eq(bang_config)
      end
    end

    context 'directory directive and default directive present' do
      let(:directory) { 'spec/samples/two_smelly_files/' }
      let(:directory_config) { { Reek::SmellDetectors::TooManyStatements => { max_statements: 8 } } }
      let(:directory_directives) { { directory => directory_config } }
      let(:default_directive) do
        {
          Reek::SmellDetectors::IrresponsibleModule => { enabled: false },
          Reek::SmellDetectors::TooManyStatements => { max_statements: 15 }
        }
      end
      let(:source_via) { "#{directory}/dummy.rb" }
      let(:configuration_as_hash) { directory_directives.merge(default_directive) }

      it 'returns the directory directive with the default directive reverse-merged' do
        configuration = described_class.from_hash configuration_as_hash
        actual = configuration.directive_for(source_via)

        expect(actual[Reek::SmellDetectors::IrresponsibleModule]).to be_truthy
        expect(actual[Reek::SmellDetectors::TooManyStatements]).to be_truthy
        expect(actual[Reek::SmellDetectors::TooManyStatements][:max_statements]).to eq(8)
      end
    end

    context 'no directory directive but a default directive present' do
      let(:source_via) { 'spec/samples/three_clean_files/dummy.rb' }
      let(:default_directive) { { Reek::SmellDetectors::IrresponsibleModule => { enabled: false } } }
      let(:attribute_config) { { Reek::SmellDetectors::Attribute => { enabled: false } } }
      let(:directory_directives) do
        { 'spec/samples/two_smelly_files' => attribute_config }
      end
      let(:configuration_as_hash) { directory_directives.merge(default_directive) }

      it 'returns the default directive' do
        configuration = described_class.from_hash configuration_as_hash
        expect(configuration.directive_for(source_via)).to eq(default_directive)
      end
    end
  end
end
