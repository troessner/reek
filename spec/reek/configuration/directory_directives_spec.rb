require_relative '../../spec_helper'
require_lib 'reek/configuration/directory_directives'

RSpec.describe Reek::Configuration::DirectoryDirectives do
  describe '#directive_for' do
    let(:baz_config)  { { Reek::Smells::IrresponsibleModule => { enabled: false } } }
    let(:bang_config) { { Reek::Smells::Attribute => { enabled: true } } }
    subject do
      {
        Pathname.new('foo/bar/baz')  => baz_config,
        Pathname.new('foo/bar/bang') => bang_config
      }.extend(described_class)
    end
    let(:source_via) { 'foo/bar/bang/dummy.rb' }

    context 'our source is in a directory for which we have a directive' do
      it 'returns the corresponding directive' do
        expect(subject.directive_for(source_via)).to eq(bang_config)
      end
    end

    context 'our source is not in a directory for which we have a directive' do
      it 'returns nil' do
        expect(subject.directive_for('does/not/exist')).to eq(nil)
      end
    end
  end

  describe '#add' do
    subject do
      {}.extend(described_class)
    end
    let(:empty_config) { Hash.new }

    context 'one of given paths does not exist' do
      let(:bogus_path) { Pathname('does/not/exist') }

      it 'raises an error' do
        Reek::CLI::Silencer.silently do
          expect { subject.add(bogus_path, {}) }.to raise_error(SystemExit)
        end
      end
    end

    context 'one of given paths is a file' do
      let(:file_as_path) { SAMPLES_PATH.join('inline.rb') }

      it 'raises an error' do
        Reek::CLI::Silencer.silently do
          expect { subject.add(file_as_path, {}) }.to raise_error(SystemExit)
        end
      end
    end
  end

  describe '#best_match_for' do
    subject do
      {
        Pathname.new('foo/bar/baz')  => {},
        Pathname.new('foo/bar')      => {},
        Pathname.new('bar/boo')      => {}
      }.extend(described_class)
    end

    it 'returns the corresponding directory when source_base_dir is a leaf' do
      source_base_dir = 'foo/bar/baz/bang'
      hit = subject.send :best_match_for, source_base_dir
      expect(hit.to_s).to eq('foo/bar/baz')
    end

    it 'returns the corresponding directory when source_base_dir is in the middle of the tree' do
      source_base_dir = 'foo/bar'
      hit = subject.send :best_match_for, source_base_dir
      expect(hit.to_s).to eq('foo/bar')
    end

    it 'returns nil we are on top of the tree and all other directories are below' do
      source_base_dir = 'foo'
      hit = subject.send :best_match_for, source_base_dir
      expect(hit).to be_nil
    end

    it 'returns nil when source_base_dir is not part of any directory directive at all' do
      source_base_dir = 'non/existent'
      hit = subject.send :best_match_for, source_base_dir
      expect(hit).to be_nil
    end
  end
end
