require 'spec_helper'
require 'find'

release_timestamp_file = 'build/.last-release'
if test('f', release_timestamp_file)
  describe 'updates' do
    before :each do
      @release_time = File.stat(release_timestamp_file).mtime
    end

    context 'version file' do
      it 'has been updated since the last release' do
        version_time = File.stat('lib/reek.rb').mtime
        expect(version_time).to be > @release_time
      end
    end

    context 'history file' do
      it 'has been updated since the last release' do
        history_time = File.stat('History.txt').mtime
        expect(history_time).to be > @release_time
      end
    end
  end
end
