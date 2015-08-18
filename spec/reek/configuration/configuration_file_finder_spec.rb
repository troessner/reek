# encoding: UTF-8

require 'fileutils'
require 'pathname'
require 'tmpdir'
require_relative '../../spec_helper'

RSpec.describe Reek::Configuration::ConfigurationFileFinder do
  describe '.find' do
    it 'returns the path if it’s set' do
      path = Pathname.new 'foo/bar'
      found = described_class.find(path: path)
      expect(found).to eq(path)
    end

    it 'returns the file in current dir if config_file is nil' do
      found = described_class.find(current: SAMPLES_PATH)
      expect(found).to eq(SAMPLES_PATH.join('exceptions.reek'))
    end

    it 'returns the file in current dir if options is nil' do
      found = described_class.find(current: SAMPLES_PATH)
      expect(found).to eq(SAMPLES_PATH.join('exceptions.reek'))
    end

    it 'returns the file in a parent dir if none in current dir' do
      found = described_class.find(current: SAMPLES_PATH.join('no_config_file'))
      expect(found).to eq(SAMPLES_PATH.join('exceptions.reek'))
    end

    it 'returns the file even if it’s just ‘.reek’' do
      found = described_class.find(current: SAMPLES_PATH.join('masked_by_dotfile'))
      expect(found).to eq(SAMPLES_PATH.join('masked_by_dotfile/.reek'))
    end

    it 'returns the file in home if traversing from the current dir fails' do
      skip_if_a_config_in_tempdir
      Dir.mktmpdir do |tempdir|
        current = Pathname.new(tempdir)
        found = described_class.find(current: current, home: SAMPLES_PATH)
        expect(found).to eq(SAMPLES_PATH.join('exceptions.reek'))
      end
    end

    it 'returns nil when there are no files to find' do
      skip_if_a_config_in_tempdir
      Dir.mktmpdir do |tempdir|
        current = Pathname.new(tempdir)
        home    = Pathname.new(tempdir)
        found = described_class.find(current: current, home: home)
        expect(found).to be_nil
      end
    end

    it 'works with paths that need escaping' do
      Dir.mktmpdir("ma\ngic d*r") do |tempdir|
        config = Pathname.new("#{tempdir}/ma\ngic f*le.reek")
        subdir = Pathname.new("#{tempdir}/ma\ngic subd*r")
        FileUtils.touch config
        FileUtils.mkdir subdir
        found = described_class.find(current: subdir)
        expect(found).to eq(config)
      end
    end

    describe '.load_from_file' do
      let(:sample_configuration_path) do
        SAMPLES_PATH.join('configuration/simple_configuration.reek')
      end
      let(:sample_configuration_loaded) do
        {
          'UncommunicativeVariableName' => { 'enabled' => false },
          'UncommunicativeMethodName'   => { 'enabled' => false }
        }
      end

      it 'loads the configuration from given file' do
        configuration = described_class.load_from_file(sample_configuration_path)
        expect(configuration).to eq(sample_configuration_loaded)
      end
    end

    private

    def skip_if_a_config_in_tempdir
      found = described_class.find(current: Pathname.new(Dir.tmpdir))
      skip "skipped: #{found} exists and would fail this test" if found
    end
  end
end
