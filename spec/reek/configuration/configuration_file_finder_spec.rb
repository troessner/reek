require 'fileutils'
require 'pathname'
require 'tmpdir'
require_relative '../../spec_helper'
require_lib 'reek/configuration/app_configuration'

RSpec.describe Reek::Configuration::ConfigurationFileFinder do
  describe '.find' do
    let(:regular_configuration_dir) { CONFIGURATION_DIR.join('regular_configuration') }
    let(:regular_configuration_file) { regular_configuration_dir.join('.reek.yml') }

    it 'returns any explicitely passed path' do
      path = Pathname.new 'foo/bar'
      found = described_class.find(path: path)
      expect(found).to eq(path)
    end

    it 'prefers an explicitely passed path over a file in current dir' do
      path = Pathname.new 'foo/bar'
      found = described_class.find(path: path, current: regular_configuration_dir)
      expect(found).to eq(path)
    end

    it 'returns the file in current dir if path is not set' do
      found = described_class.find(current: regular_configuration_dir)
      expect(found).to eq(regular_configuration_file)
    end

    it 'returns the file in a parent dir if none in current dir' do
      empty_sub_directory = CONFIGURATION_DIR.join('regular_configuration').join('empty_sub_directory')
      found = described_class.find(current: empty_sub_directory)
      expect(found).to eq(regular_configuration_file)
    end

    it 'skips files ending in .reek.yml in current dir' do
      skip_if_a_config_in_tempdir

      Dir.mktmpdir do |tempdir|
        current = Pathname.new(tempdir)
        bad_config = current.join('ignoreme.reek.yml')
        FileUtils.touch bad_config
        found = described_class.find(current: current)
        expect(found).to be_nil
      end
    end

    it 'returns the file in home if traversing from the current dir fails' do
      skip_if_a_config_in_tempdir

      Dir.mktmpdir do |tempdir|
        found = described_class.find(current: Pathname.new(tempdir), home: regular_configuration_dir)
        expect(found).to eq(regular_configuration_file)
      end
    end

    it 'prefers the file in :current over one in :home' do
      home_dir = CONFIGURATION_DIR.join('home')
      found = described_class.find(current: regular_configuration_dir, home: home_dir)
      expect(found).to eq(regular_configuration_file)
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
        current = Pathname.new(tempdir)
        home = SAMPLES_DIR.join('no_config_file')

        found = described_class.find(current: current, home: home)

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
        Reek::DETECTORS_KEY => {
          'UncommunicativeVariableName' => { 'enabled' => false },
          'UncommunicativeMethodName'   => { 'enabled' => false }
        }
      }
    end

    it 'loads the configuration from given file' do
      configuration = described_class.load_from_file(CONFIGURATION_DIR.join('full_mask.reek'))
      expect(configuration).to eq(sample_configuration_loaded)
    end

    it 'raises an error if it can not find the given file' do
      Dir.mktmpdir do |tempdir|
        path = Pathname.new(tempdir).join('does_not_exist.reek')
        expect { described_class.load_from_file(path) }.
          to raise_error(Reek::Errors::ConfigFileError, /Invalid configuration file/)
      end
    end

    context 'with exclude, accept and reject settings' do
      context 'when configuring top level detectors' do
        let(:configuration) do
          described_class.
            load_from_file(CONFIGURATION_DIR.join('accepts_rejects_and_excludes_for_detectors.reek.yml')).
            fetch(Reek::DETECTORS_KEY)
        end

        let(:expected) do
          {
            'UnusedPrivateMethod'          => { 'exclude' => [/exclude regexp/] },
            'UncommunicativeMethodName'    => { 'reject' => ['reject name'],
                                                'accept' => ['accept name'] },
            'UncommunicativeModuleName'    => { 'reject' => ['reject name 1', 'reject name 2'],
                                                'accept' => ['accept name 1', 'accept name 2'] },
            'UncommunicativeParameterName' => { 'reject' => ['reject name', /reject regexp/],
                                                'accept' => ['accept name', /accept regexp/] },
            'UncommunicativeVariableName'  => { 'reject' => [/^reject regexp$/],
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

      context 'when configuring directory directives' do
        let(:directory_name) { 'app/controllers' }
        let(:configuration) do
          described_class.
            load_from_file(CONFIGURATION_DIR.join('accepts_rejects_and_excludes_for_directory_directives.reek.yml')).
            fetch(Reek::DIRECTORIES_KEY)
        end

        let(:expected) do
          {
            directory_name => {
              'UnusedPrivateMethod'          => { 'exclude' => [/exclude regexp/] },
              'UncommunicativeMethodName'    => { 'reject' => ['reject name'],
                                                  'accept' => ['accept name'] },
              'UncommunicativeModuleName'    => { 'reject' => ['reject name 1', 'reject name 2'],
                                                  'accept' => ['accept name 1', 'accept name 2'] },
              'UncommunicativeParameterName' => { 'reject' => ['reject name', /reject regexp/],
                                                  'accept' => ['accept name', /accept regexp/] },
              'UncommunicativeVariableName'  => { 'reject' => [/^reject regexp$/],
                                                  'accept' => [/accept(.*)regexp/] }
            }
          }
        end

        it 'converts marked strings to regexes' do
          expect(configuration[directory_name]['UnusedPrivateMethod']).
            to eq(expected[directory_name]['UnusedPrivateMethod'])
        end

        it 'leaves regular single strings untouched' do
          expect(configuration[directory_name]['UncommunicativeMethodName']).
            to eq(expected[directory_name]['UncommunicativeMethodName'])
        end

        it 'leaves regular multiple strings untouched' do
          expect(configuration[directory_name]['UncommunicativeModuleName']).
            to eq(expected[directory_name]['UncommunicativeModuleName'])
        end

        it 'allows mixing of regular strings and marked strings' do
          expect(configuration[directory_name]['UncommunicativeParameterName']).
            to eq(expected[directory_name]['UncommunicativeParameterName'])
        end

        it 'converts more complex marked strings correctly to regexes' do
          expect(configuration[directory_name]['UncommunicativeVariableName']).
            to eq(expected[directory_name]['UncommunicativeVariableName'])
        end
      end
    end

    it 'returns blank hash when no file is found' do
      config = described_class.load_from_file(nil)

      expect(config).to eq({})
    end
  end

  private

  def skip_if_a_config_in_tempdir
    found = described_class.find(current: Pathname.new(Dir.tmpdir))
    skip "skipped: #{found} exists and would fail this test" if found
  end
end
