# encoding: UTF-8

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
      expect(found).to eq(SAMPLES_PATH.join('exceptions.reek'))
    end

    it 'returns the file in a parent dir if none in current dir' do
      Dir.mktmpdir(nil, SAMPLES_PATH) do |tempdir|
        found = described_class.find(current: Pathname.new(tempdir))
        expect(found).to eq(SAMPLES_PATH.join('exceptions.reek'))
      end
    end

    it 'returns the file even if it’s just ‘.reek’' do
      single_configuration_file_dir = CONFIG_PATH.join('single_configuration_file')
      found = described_class.find(current: single_configuration_file_dir)
      expect(found).to eq(single_configuration_file_dir.join('.reek'))
    end

    it 'returns the file in home if traversing from the current dir fails' do
      skip_if_a_config_in_tempdir

      Dir.mktmpdir(nil, SAMPLES_PATH) do |tempdir|
        found = described_class.find(current: Pathname.new(tempdir))
        expect(found).to eq(SAMPLES_PATH.join('exceptions.reek'))
      end
    end

    it 'prefers the file in :current over one in :home' do
      found = described_class.find(current: SAMPLES_PATH, home: CONFIG_PATH)
      file_in_current = SAMPLES_PATH.join('exceptions.reek')

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
        config = Pathname.new("#{tempdir}/ma\ngic f*le.reek")
        subdir = Pathname.new("#{tempdir}/ma\ngic subd*r")
        FileUtils.touch config
        FileUtils.mkdir subdir
        found = described_class.find(current: subdir)
        expect(found).to eq(config)
      end
    end

    context 'more than one configuration file' do
      let(:path) { CONFIG_PATH.join('more_than_one_configuration_file') }

      it 'prints a message on STDERR' do
        expected_message = "Error: Found multiple configuration files 'regular.reek', 'todo.reek'"
        expect do
          begin
            described_class.find(current: path)
          rescue SystemExit
          end
        end.to output(/#{expected_message}/).to_stderr
      end

      it 'exits' do
        Reek::CLI::Silencer.silently do
          expect do
            described_class.find(current: path)
          end.to raise_error(SystemExit)
        end
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
  end

  private

  def skip_if_a_config_in_tempdir
    found = described_class.find(current: Pathname.new(Dir.tmpdir))
    skip "skipped: #{found} exists and would fail this test" if found
  end
end
