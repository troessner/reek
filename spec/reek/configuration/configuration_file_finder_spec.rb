# encoding: UTF-8

require 'pathname'
require 'tmpdir'
require 'spec_helper'

describe ConfigurationFileFinder do
  describe '.find' do
    it 'returns the config_file if it’s set' do
      config_file = double
      options = double(config_file: config_file)
      found = ConfigurationFileFinder.find(options: options)
      expect(found).to eq(config_file)
    end

    it 'returns the file in current dir if config_file is nil' do
      options = double(config_file: nil)
      current = Pathname.new('spec/samples')
      found = ConfigurationFileFinder.find(options: options, current: current)
      expect(found).to eq(Pathname.new('spec/samples/exceptions.reek'))
    end

    it 'returns the file in current dir if options is nil' do
      current = Pathname.new('spec/samples')
      found = ConfigurationFileFinder.find(current: current)
      expect(found).to eq(Pathname.new('spec/samples/exceptions.reek'))
    end

    it 'returns the file in a parent dir if none in current dir' do
      current = Pathname.new('spec/samples/no_config_file')
      found = ConfigurationFileFinder.find(current: current)
      expect(found).to eq(Pathname.new('spec/samples/exceptions.reek'))
    end

    it 'returns the file even if it’s just ‘.reek’' do
      current = Pathname.new('spec/samples/masked_by_dotfile')
      found = ConfigurationFileFinder.find(current: current)
      expect(found).to eq(Pathname.new('spec/samples/masked_by_dotfile/.reek'))
    end

    it 'returns the file in home if traversing from the current dir fails' do
      Dir.mktmpdir do |tempdir|
        current = Pathname.new(tempdir)
        home    = Pathname.new('spec/samples')
        found = ConfigurationFileFinder.find(current: current, home: home)
        expect(found).to eq(Pathname.new('spec/samples/exceptions.reek'))
      end
    end

    it 'returns nil when there are no files to find' do
      Dir.mktmpdir do |tempdir|
        current = Pathname.new(tempdir)
        home    = Pathname.new(tempdir)
        found = ConfigurationFileFinder.find(current: current, home: home)
        expect(found).to be_nil
      end
    end
  end
end
