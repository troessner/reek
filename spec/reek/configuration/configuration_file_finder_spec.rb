# encoding: UTF-8

require 'fileutils'
require 'pathname'
require 'tmpdir'
require_relative '../../spec_helper'

RSpec.describe Reek::Configuration::ConfigurationFileFinder do
  describe '.find' do
    it 'returns the config_file if it’s set' do
      config_file = double
      options = double(config_file: config_file)
      found = described_class.find(options: options)
      expect(found).to eq(config_file)
    end

    it 'returns the file in current dir if config_file is nil' do
      options = double(config_file: nil)
      current = Pathname.new('spec/samples')
      found = described_class.find(options: options, current: current)
      expect(found).to eq(Pathname.new('spec/samples/exceptions.reek'))
    end

    it 'returns the file in current dir if options is nil' do
      current = Pathname.new('spec/samples')
      found = described_class.find(current: current)
      expect(found).to eq(Pathname.new('spec/samples/exceptions.reek'))
    end

    it 'returns the file in a parent dir if none in current dir' do
      current = Pathname.new('spec/samples/no_config_file')
      found = described_class.find(current: current)
      expect(found).to eq(Pathname.new('spec/samples/exceptions.reek'))
    end

    it 'returns the file even if it’s just ‘.reek’' do
      current = Pathname.new('spec/samples/masked_by_dotfile')
      found = described_class.find(current: current)
      expect(found).to eq(Pathname.new('spec/samples/masked_by_dotfile/.reek'))
    end

    it 'returns the file in home if traversing from the current dir fails' do
      skip_if_a_config_in_tempdir
      Dir.mktmpdir do |tempdir|
        current = Pathname.new(tempdir)
        home    = Pathname.new('spec/samples')
        found = described_class.find(current: current, home: home)
        expect(found).to eq(Pathname.new('spec/samples/exceptions.reek'))
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

    private

    def skip_if_a_config_in_tempdir
      found = described_class.find(current: Pathname.new(Dir.tmpdir))
      skip "skipped: #{found} exists and would fail this test" if found
    end
  end
end
