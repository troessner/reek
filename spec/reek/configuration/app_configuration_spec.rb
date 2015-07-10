require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/reek/configuration/app_configuration'
require_relative '../../../lib/reek/smells/smell_repository'

RSpec.describe Reek::Configuration::AppConfiguration do
  let(:sample_configuration_path) do
    Pathname('spec/samples/configuration/simple_configuration.reek')
  end
  let(:sample_configuration_loaded) do
    {
      'UncommunicativeVariableName' => { 'enabled' => false },
      'UncommunicativeMethodName'   => { 'enabled' => false }
    }
  end
  let(:default_configuration) { Hash.new }

  after(:each) { described_class.reset }

  describe '.initialize_with' do
    it 'loads a configuration file if it can find one' do
      finder = Reek::Configuration::ConfigurationFileFinder
      allow(finder).to receive(:find).and_return sample_configuration_path
      expect(described_class.configuration).to eq(default_configuration)

      described_class.initialize_with(nil)
      expect(described_class.configuration).to eq(sample_configuration_loaded)
    end

    it 'leaves the default configuration untouched if it can\'t find one' do
      allow(Reek::Configuration::ConfigurationFileFinder).to receive(:find).and_return nil
      expect(described_class.configuration).to eq(default_configuration)

      described_class.initialize_with(nil)
      expect(described_class.configuration).to eq(default_configuration)
    end
  end

  describe '.configure_smell_repository' do
    it 'should configure a given smell_repository' do
      described_class.load_from_file(sample_configuration_path)
      smell_repository = Reek::Smells::SmellRepository.new('def m; end')
      described_class.configure_smell_repository smell_repository

      expect(smell_repository.detectors[Reek::Smells::DataClump]).to be_enabled
      expect(smell_repository.detectors[Reek::Smells::UncommunicativeVariableName]).
        not_to be_enabled
      expect(smell_repository.detectors[Reek::Smells::UncommunicativeMethodName]).not_to be_enabled
    end
  end

  describe '.exclude_paths' do
    let(:config_path) do
      Pathname('spec/samples/configuration/with_excluded_paths.reek')
    end

    it 'should return all paths to exclude' do
      with_test_config(config_path) do
        expect(described_class.exclude_paths).to eq [
          Pathname('spec/samples/source_with_exclude_paths/ignore_me'),
          Pathname('spec/samples/source_with_exclude_paths/nested/ignore_me_as_well')
        ]
      end
    end
  end

  describe '.load_from_file' do
    it 'loads the configuration from given file' do
      described_class.load_from_file(sample_configuration_path)
      expect(described_class.configuration).to eq(sample_configuration_loaded)
    end
  end

  describe '.reset' do
    it 'resets the configuration' do
      described_class.load_from_file(sample_configuration_path)

      expect(described_class.configuration).to eq(sample_configuration_loaded)
      described_class.reset
      expect(described_class.configuration).to eq(default_configuration)
      expect(described_class.exclude_paths).to be_empty
    end
  end
end
