require 'spec_helper'
require 'reek/configuration/app_configuration'
require 'reek/core/smell_repository'

include Reek::Configuration
include Reek::Core

describe AppConfiguration do
  let(:sample_configuration_path) { 'spec/samples/simple_configuration.reek' }
  let(:sample_configuration_loaded) do
    {
      'UncommunicativeVariableName' => { 'enabled' => false },
      'UncommunicativeMethodName'   => { 'enabled' => false }
    }
  end
  let(:default_configuration) { Hash.new }

  after(:each) { AppConfiguration.reset }

  describe '.initialize_with' do
    it 'loads a configuration file if it can find one' do
      allow(ConfigurationFileFinder).to receive(:find).and_return sample_configuration_path
      expect(AppConfiguration.configuration).to eq(default_configuration)

      AppConfiguration.initialize_with(nil)
      expect(AppConfiguration.configuration).to eq(sample_configuration_loaded)
    end

    it 'leaves the default configuration untouched if it can\'t find one' do
      allow(ConfigurationFileFinder).to receive(:find).and_return nil
      expect(AppConfiguration.configuration).to eq(default_configuration)

      AppConfiguration.initialize_with(nil)
      expect(AppConfiguration.configuration).to eq(default_configuration)
    end
  end

  describe '.configure_smell_repository' do
    it 'should configure a given smell_repository' do
      AppConfiguration.load_from_file(sample_configuration_path)
      smell_repository = SmellRepository.new('def m; end')
      AppConfiguration.configure_smell_repository smell_repository

      expect(smell_repository.detectors[Reek::Smells::DataClump]).to be_enabled
      expect(smell_repository.detectors[Reek::Smells::UncommunicativeVariableName]).
        not_to be_enabled
      expect(smell_repository.detectors[Reek::Smells::UncommunicativeMethodName]).not_to be_enabled
    end
  end

  describe '.load_from_file' do
    it 'loads the configuration from given file' do
      AppConfiguration.load_from_file(sample_configuration_path)
      expect(AppConfiguration.configuration).to eq(sample_configuration_loaded)
    end
  end

  describe '.reset' do
    it 'resets the configuration' do
      AppConfiguration.load_from_file(sample_configuration_path)

      expect(AppConfiguration.configuration).to eq(sample_configuration_loaded)
      AppConfiguration.reset
      expect(AppConfiguration.configuration).to eq(default_configuration)
    end
  end
end
