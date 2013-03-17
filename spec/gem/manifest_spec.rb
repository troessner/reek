require 'spec_helper'
require 'find'

describe 'gem manifest' do
  before :each do
    @current_files = []
    Find.find '.' do |path|
      next unless File.file? path
      next if path =~ /\.git|\.idea|build|doc|gem\/|tmp|nbproject|quality|xp.reek|Manifest.txt|develop.rake|deployment.rake/
      @current_files << path[2..-1]
    end
    @current_files.sort!
    @manifest = IO.readlines('Manifest.txt').map {|path| path.chomp}.sort
  end

  it 'lists every current file' do
    (@current_files - @manifest).should == []
  end
  it 'lists no extra files' do
    (@manifest - @current_files).should == []
  end
end
