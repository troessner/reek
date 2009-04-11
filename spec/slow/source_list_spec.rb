require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/source'

include Reek

describe SourceList, 'from_pathlist' do

  describe 'with no smells in any source' do
    before :each do
      @src = Dir['lib/reek/*.rb'].to_source
    end

    it 'reports no smells' do
      @src.report.length.should == 0
    end

    it 'is empty' do
      @src.report.should be_empty
    end
  end

  describe 'with smells in one source' do
    before :each do
      @src = Source.from_pathlist(["#{SAMPLES_DIR}/inline.rb", 'lib/reek.rb'])
    end

    it 'reports some smells in the samples' do
      @src.report.should have_at_least(30).smells
    end

    it 'is smelly' do
      @src.should be_smelly
    end

    it 'reports an UncommunicativeName' do
      @src.report.any? {|warning| warning.report =~ /Uncommunicative Name/}.should be_true
    end
  end
end
