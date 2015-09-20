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
      it 'properly sets the configuration' do
        config = described_class.from_map(directory_directives: expected_directory_directives,
                                          default_directive: expected_default_directive,
                                          excluded_paths: expected_excluded_paths)

        expect(config.send(:excluded_paths)).to eq(expected_excluded_paths)
        expect(config.send(:default_directive)).to eq(expected_default_directive)
        expect(config.send(:directory_directives)).to eq(expected_directory_directives)
      end
    end
  end

  describe '#directive_for' do
    context 'our source is in a directory for which we have a directive' do
      let(:baz_config)  { { Reek::Smells::IrresponsibleModule => { enabled: false } } }
      let(:bang_config) { { Reek::Smells::Attribute => { enabled: true } } }

      let(:directory_directives) do
        {
          Pathname.new('foo/bar/baz')  => baz_config,
          Pathname.new('foo/bar/bang') => bang_config
        }
      end
      let(:source_via) { 'foo/bar/bang/dummy.rb' }

      it 'returns the corresponding directive' do
        configuration = described_class.from_map directory_directives: directory_directives
        expect(configuration.directive_for(source_via)).to eq(bang_config)
      end
    end

    context 'our source is not in a directory for which we have a directive' do
      let(:irresponsible_module_config) do
        { Reek::Smells::IrresponsibleModule => { enabled: false } }
      end
      let(:attribute_config) { { Reek::Smells::Attribute => { enabled: false } } }
      let(:default_directive) do
        irresponsible_module_config
      end
      let(:directory_directives) do
        { Pathname.new('foo/bar/baz') => attribute_config }
      end
      let(:source_via) { 'foo/bar/bang/dummy.rb' }

      it 'returns the default directive' do
        configuration = described_class.from_map directory_directives: directory_directives,
                                                 default_directive: default_directive
        expect(configuration.directive_for(source_via)).to eq(irresponsible_module_config)
      end
    end
  end
end
