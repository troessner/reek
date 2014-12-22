require 'spec_helper'
require 'reek/cli/application'

include Reek::Cli
include Reek::Configuration

describe ConfigurationFileFinder do
  describe '.find' do
    let(:sample_config_path) { Pathname.new('spec/samples/simple_configuration.reek') }
    let(:config_path_same_level) { Pathname.new('spec/samples/simple_configuration.reek') }
    let(:options) { double(config_file: sample_config_path) }
    let(:application_with_options) { double(options: options) }
    let(:application_without_options) { nil }

    it 'should return the config file we passed as cli option if given' do
      expect(ConfigurationFileFinder.find(application_with_options)).to eq(sample_config_path)
    end

    it 'should return the first configuration file it can find in the current directory' do
      allow(ConfigurationFileFinder).to receive(:detect_or_traverse_up).
        and_return config_path_same_level

      expect(ConfigurationFileFinder.find(application_without_options)).
        to eq(config_path_same_level)
    end

    it 'should look in the HOME directory lastly' do
      allow(ConfigurationFileFinder).to receive(:configuration_by_cli).and_return nil
      allow(ConfigurationFileFinder).to receive(:configuration_in_file_system).and_return nil
      expect(ConfigurationFileFinder).to receive(:configuration_in_home_directory).once

      ConfigurationFileFinder.find application_without_options
    end
  end
end
