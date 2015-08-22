require_relative '../spec_helper'
require 'find'

release_timestamp_file = 'build/.last-release'

if test('f', release_timestamp_file)
  describe 'updates' do
    let(:release_time) { File.stat(release_timestamp_file).mtime }

    context 'version file' do
      it 'has been updated since the last release' do
        expect(File.stat('lib/reek/version.rb').mtime).to be > release_time
      end
    end

    context 'history file' do
      it 'has been updated since the last release' do
        expect(File.stat('History.txt').mtime).to be > release_time
      end
    end
  end
end
