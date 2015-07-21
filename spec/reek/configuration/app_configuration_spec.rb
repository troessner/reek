require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/reek/configuration/app_configuration'
require_relative '../../../lib/reek/smells/smell_repository'
require_relative '../../../lib/reek/source/source_code'

RSpec.describe Reek::Configuration::AppConfiguration do
  describe '#initialize' do
    let(:full_configuration_path) { SAMPLES_PATH.join('configuration/full_configuration.reek') }
    let(:expected_exclude_paths) do
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

    it 'properly loads configuration and processes it' do
      finder = Reek::Configuration::ConfigurationFileFinder
      allow(finder).to receive(:find_by_cli).and_return full_configuration_path

      expect(subject.exclude_paths).to eq(expected_exclude_paths)
      expect(subject.default_directive).to eq(expected_default_directive)
      expect(subject.directory_directives).to eq(expected_directory_directives)
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
        allow(subject).to receive(:directory_directives).and_return directory_directives
        expect(subject.directive_for(source_via)).to eq(bang_config)
      end
    end

    context 'our source is not in a directory for which we have a directive' do
      let(:baz_config)  { { Reek::Smells::IrresponsibleModule => { enabled: false } } }
      let(:default_directive) do
        { Reek::Smells::Attribute => { enabled: true } }
      end
      let(:directory_directives) do
        { Pathname.new('foo/bar/baz')  => baz_config }
      end
      let(:source_via) { 'foo/bar/bang/dummy.rb' }

      it 'returns the default directive' do
        allow(subject).to receive(:directory_directives).and_return directory_directives
        allow(subject).to receive(:default_directive).and_return default_directive
        expect(subject.directive_for(source_via)).to eq(default_directive)
      end
    end
  end

  describe '#best_directory_match_for' do
    let(:directory_directives) do
      {
        Pathname.new('foo/bar/baz')  => {},
        Pathname.new('foo/bar')      => {},
        Pathname.new('bar/boo')      => {}
      }
    end

    before do
      allow(subject).to receive(:directory_directives).and_return directory_directives
    end

    it 'returns the corresponding directory when source_base_dir is a leaf' do
      source_base_dir = 'foo/bar/baz/bang'
      hit = subject.send :best_directory_match_for, source_base_dir
      expect(hit.to_s).to eq('foo/bar/baz')
    end

    it 'returns the corresponding directory when source_base_dir is in the middle of the tree' do
      source_base_dir = 'foo/bar'
      hit = subject.send :best_directory_match_for, source_base_dir
      expect(hit.to_s).to eq('foo/bar')
    end

    it 'returns nil we are on top at the top of the and all other directories are below' do
      source_base_dir = 'foo'
      hit = subject.send :best_directory_match_for, source_base_dir
      expect(hit).to be_nil
    end

    it 'returns nil when there source_base_dir is not part of any directory directive at all' do
      source_base_dir = 'non/existent'
      hit = subject.send :best_directory_match_for, source_base_dir
      expect(hit).to be_nil
    end
  end
end
