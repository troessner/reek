require_relative '../../spec_helper'
require_relative '../../../lib/reek/configuration/app_configuration'
require_relative '../../../lib/reek/core/smell_repository'

RSpec.describe Reek::Configuration::AppConfiguration do
  let(:sample_configuration_path) { 'spec/samples/simple_configuration.reek' }
  let(:sample_configuration_loaded) do
    {
      'UncommunicativeVariableName' => { 'enabled' => false },
      'UncommunicativeMethodName'   => { 'enabled' => false }
    }
  end
  let(:default_configuration) { Hash.new }

  after(:each) { Reek::Configuration::AppConfiguration.reset }

  describe '.initialize_with' do
    it 'loads a configuration file if it can find one' do
      finder = Reek::Configuration::ConfigurationFileFinder
      allow(finder).to receive(:find).and_return sample_configuration_path
      expect(Reek::Configuration::AppConfiguration.configuration).to eq(default_configuration)

      Reek::Configuration::AppConfiguration.initialize_with(nil)
      expect(Reek::Configuration::AppConfiguration.configuration).to eq(sample_configuration_loaded)
    end

    it 'leaves the default configuration untouched if it can\'t find one' do
      allow(Reek::Configuration::ConfigurationFileFinder).to receive(:find).and_return nil
      expect(Reek::Configuration::AppConfiguration.configuration).to eq(default_configuration)

      Reek::Configuration::AppConfiguration.initialize_with(nil)
      expect(Reek::Configuration::AppConfiguration.configuration).to eq(default_configuration)
    end
  end

  describe '.configure_smell_repository' do
    it 'should configure a given smell_repository' do
      Reek::Configuration::AppConfiguration.load_from_file(sample_configuration_path)
      smell_repository = Reek::Core::SmellRepository.new('def m; end')
      Reek::Configuration::AppConfiguration.configure_smell_repository smell_repository

      expect(smell_repository.detectors[Reek::Smells::DataClump]).to be_enabled
      expect(smell_repository.detectors[Reek::Smells::UncommunicativeVariableName]).
        not_to be_enabled
      expect(smell_repository.detectors[Reek::Smells::UncommunicativeMethodName]).not_to be_enabled
    end
  end

  describe '.load_from_file' do
    it 'loads the configuration from given file' do
      Reek::Configuration::AppConfiguration.load_from_file(sample_configuration_path)
      expect(Reek::Configuration::AppConfiguration.configuration).to eq(sample_configuration_loaded)
    end
  end

  describe '.reset' do
    it 'resets the configuration' do
      Reek::Configuration::AppConfiguration.load_from_file(sample_configuration_path)

      expect(Reek::Configuration::AppConfiguration.configuration).to eq(sample_configuration_loaded)
      Reek::Configuration::AppConfiguration.reset
      expect(Reek::Configuration::AppConfiguration.configuration).to eq(default_configuration)
    end
  end
end
