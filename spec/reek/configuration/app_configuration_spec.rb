require 'pathname'
require_relative '../../spec_helper'
require_lib 'reek/configuration/app_configuration'
require_lib 'reek/configuration/directory_directives'
require_lib 'reek/configuration/default_directive'
require_lib 'reek/configuration/excluded_paths'

RSpec.describe Reek::Configuration::AppConfiguration do
  describe 'factory methods' do
    around do |example|
      Dir.mktmpdir('/tmp') do |tmp|
        Dir.chdir(tmp) do
          example.run
        end
      end
    end

    let(:expected_exclude_file_names) do
      %w(exclude_me.rb exclude_me_too.rb)
    end

    let(:expected_exclude_directories) do
      %w(directory_with_trailing_slash/ directory_without_trailing_slash)
    end

    let(:expected_excluded_paths) do
      (expected_exclude_file_names + expected_exclude_directories).map { |path| Pathname(path) }
    end

    let(:expected_default_directive) do
      { Reek::SmellDetectors::IrresponsibleModule => { 'enabled' => false } }
    end

    let(:expected_directory_directives) do
      { Pathname('directory_with_some_ruby_files') =>
        { Reek::SmellDetectors::UtilityFunction => { 'enabled' => false } } }
    end

    describe '#from_path' do
      let(:configuration_path) { 'config.reek' }
      let(:configuration) do
        <<-EOF.strip_heredoc
        ---
        detectors:
          IrresponsibleModule:
            enabled: false

        directories:
          "directory_with_some_ruby_files":
            UtilityFunction:
              enabled: false

        exclude_paths:
          - "exclude_me.rb"
          - "exclude_me_too.rb"
          - "directory_with_trailing_slash/"
          - "directory_without_trailing_slash"
        EOF
      end

      before do
        File.write configuration_path, configuration
        FileUtils.touch expected_exclude_file_names
        FileUtils.mkdir expected_exclude_directories
      end

      it 'properly loads configuration and processes it' do
        config = described_class.from_path configuration_path

        expect(config.send(:excluded_paths)).to eq(expected_excluded_paths)
        expect(config.send(:default_directive)).to eq(expected_default_directive)
        expect(config.send(:directory_directives)).to eq(expected_directory_directives)
      end
    end

    describe '#from_hash' do
      before do
        FileUtils.touch expected_exclude_file_names
        FileUtils.mkdir expected_exclude_directories
      end

      let(:default_directive_value) do
        { Reek::DETECTORS_KEY =>
            { 'IrresponsibleModule' => { 'enabled' => false } } }
      end

      let(:directory_directives_value) do
        { Reek::DIRECTORIES_KEY =>
            { 'directory_with_some_ruby_files' =>
                { 'UtilityFunction' => { 'enabled' => false } } } }
      end

      let(:exclude_paths_value) do
        { Reek::EXCLUDE_PATHS_KEY => (expected_exclude_file_names + expected_exclude_directories) }
      end

      let(:combined_value) do
        directory_directives_value.
          merge(default_directive_value).
          merge(exclude_paths_value)
      end

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
    context 'with multiple directory directives and no default directive present' do
      let(:source_via) { 'samples/some_files/dummy1.rb' }
      let(:baz_config)  { { IrresponsibleModule: { enabled: false } } }
      let(:bang_config) { { Attribute: { enabled: true } } }
      let(:expected_result) { { Reek::SmellDetectors::Attribute => { enabled: true } } }

      let(:directory_directives) do
        { Reek::DIRECTORIES_KEY =>
          {
            'samples/some_files' => bang_config,
            'samples/other_files' => baz_config
          } }
      end

      it 'returns the corresponding directive' do
        configuration = described_class.from_hash directory_directives
        expect(configuration.directive_for(source_via)).to eq expected_result
      end
    end

    context 'with directory directive and default directive present' do
      let(:directory) { 'spec/samples/two_smelly_files/' }
      let(:source_via) { "#{directory}/dummy.rb" }

      let(:configuration_as_hash) do
        {
          Reek::DIRECTORIES_KEY =>
            { directory => { TooManyStatements: { max_statements: 8 } } },
          Reek::DETECTORS_KEY => {
            IrresponsibleModule: { enabled: false },
            TooManyStatements: { max_statements: 15 }
          }
        }
      end

      it 'returns the directory directive with the default directive reverse-merged' do
        configuration = described_class.from_hash configuration_as_hash
        actual = configuration.directive_for(source_via)

        expect(actual[Reek::SmellDetectors::IrresponsibleModule]).to be_truthy
        expect(actual[Reek::SmellDetectors::TooManyStatements]).to be_truthy
        expect(actual[Reek::SmellDetectors::TooManyStatements][:max_statements]).to eq(8)
      end
    end

    context 'with a path not covered by a directory directive but a default directive present' do
      let(:source_via) { 'samples/some_files/dummy.rb' }

      let(:configuration_as_hash) do
        {
          Reek::DETECTORS_KEY => {
            IrresponsibleModule: { enabled: false }
          },
          Reek::DIRECTORIES_KEY =>
            { 'samples/other_files' => { Attribute: { enabled: false } } }
        }
      end

      let(:expected_result) { { Reek::SmellDetectors::IrresponsibleModule => { enabled: false } } }

      it 'returns the default directive' do
        configuration = described_class.from_hash configuration_as_hash
        expect(configuration.directive_for(source_via)).to eq expected_result
      end
    end
  end
end
