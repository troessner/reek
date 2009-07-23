require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/adapters/report'
require 'reek/adapters/spec'

include Reek
include Reek::Spec

describe ShouldReek, 'checking code in a string' do
  before :each do
    @clean_code = 'def good() true; end'
    @smelly_code = 'def x() y = 4; end'
    @matcher = ShouldReek.new
  end

  it 'matches a smelly String' do
    @matcher.matches?(@smelly_code).should be_true
  end

  it 'doesnt match a fragrant String' do
    @matcher.matches?(@clean_code).should be_false
  end

  it 'reports the smells when should_not fails' do
    @matcher.matches?(@smelly_code).should be_true
    @matcher.failure_message_for_should_not.should include(Report.new(@smelly_code.sniff).quiet_report)
  end
end

describe ShouldReek, 'checking code in a Dir' do
  before :each do
    @clean_dir = Dir['spec/samples/three_clean_files/*.rb']
    @smelly_dir = Dir['spec/samples/two_smelly_files/*.rb']
    @matcher = ShouldReek.new
  end

  it 'matches a smelly String' do
    @matcher.matches?(@smelly_dir).should be_true
  end

  it 'doesnt match a fragrant String' do
    @matcher.matches?(@clean_dir).should be_false
  end

  it 'reports the smells when should_not fails' do
    @matcher.matches?(@smelly_dir).should be_true
    @matcher.failure_message_for_should_not.should include(Report.new(@smelly_dir.sniff.sniffers).quiet_report)
  end
end

describe ShouldReek, 'checking code in a File' do
  before :each do
    @clean_file = File.new(Dir['spec/samples/three_clean_files/*.rb'][0])
    @smelly_file = File.new(Dir['spec/samples/two_smelly_files/*.rb'][0])
    @matcher = ShouldReek.new
  end

  it 'matches a smelly String' do
    @matcher.matches?(@smelly_file).should be_true
  end

  it 'doesnt match a fragrant String' do
    @matcher.matches?(@clean_file).should be_false
  end

  it 'reports the smells when should_not fails' do
    @matcher.matches?(@smelly_file).should be_true
    @matcher.failure_message_for_should_not.should include(Report.new(@smelly_file.sniff).quiet_report)
  end
end

describe ShouldReek, 'report formatting' do
  before :each do
    sn_clean = 'def clean() @thing = 4; end'.sniff
    sn_dirty = 'def dirty() thing.cool + thing.cool; end'.sniff
    sniffers = SnifferSet.new([sn_clean, sn_dirty], '')
    @matcher = ShouldReek.new
    @matcher.matches?(sniffers)
    @lines = @matcher.failure_message_for_should_not.split("\n").map {|str| str.chomp}
    @error_message = @lines.shift
    @smells = @lines.grep(/^  /)
    @headers = (@lines - @smells)
  end

  it 'mentions every smell in the report' do
    @smells.should have(2).warnings
  end

  it 'doesnt mention the clean files' do
    @headers.should have(1).headers
  end
end
