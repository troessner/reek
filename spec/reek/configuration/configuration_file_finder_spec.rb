require 'fileutils'
require 'pathname'
require 'tmpdir'
require_relative '../../spec_helper'

RSpec.describe Reek::Configuration::ConfigurationFileFinder do
  describe '.find' do
    it 'returns any explicitely passed path' do
      path = Pathname.new 'foo/bar'
      found = described_class.find(path: path)
      expect(found).to eq(path)
    end

    it 'prefers an explicitely passed path over a file in current dir' do
      path = Pathname.new 'foo/bar'
      found = described_class.find(path: path, current: SAMPLES_PATH)
      expect(found).to eq(path)
    end

    it 'returns the file in current dir if path is not set' do
      found = described_class.find(current: SAMPLES_PATH)
      expect(found).to eq(SAMPLES_PATH.join('.reek.yml'))
    end

    it 'returns the file in a parent dir if none in current dir' do
      Dir.mktmpdir(nil, SAMPLES_PATH) do |tempdir|
        found = described_class.find(current: Pathname.new(tempdir))
        expect(found).to eq(SAMPLES_PATH.join('.reek.yml'))
      end
    end

    it 'returns the file in home if traversing from the current dir fails' do
      skip_if_a_config_in_tempdir

      Dir.mktmpdir(nil, SAMPLES_PATH) do |tempdir|
        found = described_class.find(current: Pathname.new(tempdir))
        expect(found).to eq(SAMPLES_PATH.join('.reek.yml'))
      end
    end

    it 'prefers the file in :current over one in :home' do
      found = described_class.find(current: SAMPLES_PATH, home: CONFIG_PATH)
      file_in_current = SAMPLES_PATH.join('.reek.yml')

      expect(found).to eq(file_in_current)
    end

    it 'returns nil when there are no files to find' do
      skip_if_a_config_in_tempdir

      Dir.mktmpdir do |tempdir|
        current = Pathname.new(tempdir)
        home = Pathname.new(tempdir)

        found = described_class.find(current: current, home: home)

        expect(found).to be_nil
      end
    end

    it 'does not traverse up from :home' do
      skip_if_a_config_in_tempdir

      Dir.mktmpdir do |tempdir|
        dir = Pathname.new(tempdir)
        subdir = dir.join('subdir')

        FileUtils.mkdir(subdir)

        found = described_class.find(current: subdir, home: dir)

        expect(found).to be_nil
      end
    end

    it 'works with paths that need escaping' do
      Dir.mktmpdir("ma\ngic d*r") do |tempdir|
        config = Pathname.new("#{tempdir}/.reek.yml")
        subdir = Pathname.new("#{tempdir}/ma\ngic subd*r")
        FileUtils.touch config
        FileUtils.mkdir subdir
        found = described_class.find(current: subdir)
        expect(found).to eq(config)
      end
    end
  end

  describe '.load_from_file' do
    let(:sample_configuration_loaded) do
      {
        'UncommunicativeVariableName' => { 'enabled' => false },
        'UncommunicativeMethodName'   => { 'enabled' => false }
      }
    end

    it 'loads the configuration from given file' do
      configuration = described_class.load_from_file(CONFIG_PATH.join('full_mask.reek'))
      expect(configuration).to eq(sample_configuration_loaded)
    end

    context 'with exclude, accept and reject settings' do
      let(:configuration) { described_class.load_from_file(CONFIG_PATH.join('accepts_rejects_and_excludes.reek.yml')) }
      let(:expected) do
        {
          'UnusedPrivateMethod' => { 'exclude' => [/exclude regexp/] },
          'UncommunicativeMethodName' => { 'reject' => ['reject name'],
                                           'accept' => ['accept name'] },
          'UncommunicativeModuleName' => { 'reject' => ['reject name 1', 'reject name 2'],
                                           'accept' => ['accept name 1', 'accept name 2'] },
          'UncommunicativeParameterName' => { 'reject' => ['reject name', /reject regexp/],
                                              'accept' => ['accept name', /accept regexp/] },
          'UncommunicativeVariableName' => { 'reject' => [/^reject regexp$/],
                                             'accept' => [/accept(.*)regexp/] }
        }
      end

      it 'converts marked strings to regexes' do
        expect(configuration['UnusedPrivateMethod']).to eq(expected['UnusedPrivateMethod'])
      end

      it 'leaves regular single strings untouched' do
        expect(configuration['UncommunicativeMethodName']).to eq(expected['UncommunicativeMethodName'])
      end

      it 'leaves regular multiple strings untouched' do
        expect(configuration['UncommunicativeModuleName']).to eq(expected['UncommunicativeModuleName'])
      end

      it 'allows mixing of regular strings and marked strings' do
        expect(configuration['UncommunicativeParameterName']).to eq(expected['UncommunicativeParameterName'])
      end

      it 'converts more complex marked strings correctly to regexes' do
        expect(configuration['UncommunicativeVariableName']).to eq(expected['UncommunicativeVariableName'])
      end
    end
  end

  private

  def skip_if_a_config_in_tempdir
    found = described_class.find(current: Pathname.new(Dir.tmpdir))
    skip "skipped: #{found} exists and would fail this test" if found
  end
end
