require_relative '../../spec_helper'
require_lib 'reek/configuration/directory_directives'

RSpec.describe Reek::Configuration::DirectoryDirectives do
  describe '#directive_for' do
    let(:baz_config)  { { Reek::SmellDetectors::IrresponsibleModule => { enabled: false } } }
    let(:bang_config) { { Reek::SmellDetectors::Attribute => { enabled: true } } }
    let(:directives) do
      {
        Pathname.new('foo/bar/baz')  => baz_config,
        Pathname.new('foo/bar/bang') => bang_config
      }.extend(described_class)
    end
    let(:source_via) { 'foo/bar/bang/dummy.rb' }

    context 'our source is in a directory for which we have a directive' do
      it 'returns the corresponding directive' do
        expect(directives.directive_for(source_via)).to eq(bang_config)
      end
    end

    context 'our source is not in a directory for which we have a directive' do
      it 'returns nil' do
        expect(directives.directive_for('does/not/exist')).to eq(nil)
      end
    end
  end

  describe '#add' do
    let(:directives) do
      {}.extend(described_class)
    end

    context 'one of given paths is a file' do
      let(:file_as_path) { SAMPLES_PATH.join('inline.rb') }

      it 'raises an error' do
        Reek::CLI::Silencer.silently do
          expect { directives.add(file_as_path, {}) }.to raise_error(SystemExit)
        end
      end
    end
  end

  describe '#best_match_for' do
    let(:directives) do
      {
        Pathname.new('foo/bar/baz')  => {},
        Pathname.new('foo/bar')      => {},
        Pathname.new('bar/boo')      => {}
      }.extend(described_class)
    end

    it 'returns the corresponding directory when source_base_dir is a leaf' do
      source_base_dir = 'foo/bar/baz/bang'
      hit = directives.send :best_match_for, source_base_dir
      expect(hit.to_s).to eq('foo/bar/baz')
    end

    it 'returns the corresponding directory when source_base_dir is in the middle of the tree' do
      source_base_dir = 'foo/bar'
      hit = directives.send :best_match_for, source_base_dir
      expect(hit.to_s).to eq('foo/bar')
    end

    it 'returns nil we are on top of the tree and all other directories are below' do
      source_base_dir = 'foo'
      hit = directives.send :best_match_for, source_base_dir
      expect(hit).to be_nil
    end

    it 'returns nil when source_base_dir is not part of any directory directive at all' do
      source_base_dir = 'non/existent'
      hit = directives.send :best_match_for, source_base_dir
      expect(hit).to be_nil
    end
  end
end
