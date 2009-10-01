require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/adapters/report'
require 'reek/adapters/spec'

include Reek
include Reek::Spec

describe ShouldReekOf, 'rdoc demo example' do
  it 'works on a common source' do
    ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'
    ruby.should reek_of(:Duplication, /@other.thing[^\.]/)
    ruby.should reek_of(:Duplication, /@other.thing.foo/)
    ruby.should_not reek_of(:FeatureEnvy)
  end

  it 'works on a common sniffer' do
    ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'.sniff
    ruby.should reek_of(:Duplication, /@other.thing[^\.]/)
    ruby.should reek_of(:Duplication, /@other.thing.foo/)
    ruby.should_not reek_of(:FeatureEnvy)
  end
end

describe ShouldReekOf, 'checking code in a string' do
  before :each do
    @clean_code = 'def good() true; end'
    @smelly_code = 'def x() y = 4; end'
    @matcher = ShouldReekOf.new(:UncommunicativeName, [/x/, /y/])
  end

  it 'matches a smelly String' do
    @matcher.matches?(@smelly_code).should be_true
  end

  it 'doesnt match a fragrant String' do
    @matcher.matches?(@clean_code).should be_false
  end

  it 'reports the smells when should_not fails' do
    @matcher.matches?(@smelly_code).should be_true
    @matcher.failure_message_for_should_not.should include(QuietReport.new(@smelly_code.sniff, '%m%c %w (%s)').report)
  end
end

describe ShouldReekOf, 'checking code in a Dir' do
  before :each do
    @clean_dir = Dir['spec/samples/three_clean_files/*.rb']
    @smelly_dir = Dir['spec/samples/two_smelly_files/*.rb']
    @matcher = ShouldReekOf.new(:UncommunicativeName, [/Dirty/, /@s/])
  end

  it 'matches a smelly String' do
    @matcher.matches?(@smelly_dir).should be_true
  end

  it 'doesnt match a fragrant String' do
    @matcher.matches?(@clean_dir).should be_false
  end

  it 'reports the smells when should_not fails' do
    @matcher.matches?(@smelly_dir).should be_true
    @matcher.failure_message_for_should_not.should include(QuietReport.new(@smelly_dir.sniff.sniffers, '%m%c %w (%s)').report)
  end
end

describe ShouldReekOf, 'checking code in a File' do
  before :each do
    @clean_file = File.new(Dir['spec/samples/three_clean_files/*.rb'][0])
    @smelly_file = File.new(Dir['spec/samples/two_smelly_files/*.rb'][0])
    @matcher = ShouldReekOf.new(:UncommunicativeName, [/Dirty/, /@s/])
  end

  it 'matches a smelly String' do
    @matcher.matches?(@smelly_file).should be_true
  end

  it 'doesnt match a fragrant String' do
    @matcher.matches?(@clean_file).should be_false
  end

  it 'reports the smells when should_not fails' do
    @matcher.matches?(@smelly_file).should be_true
    @matcher.failure_message_for_should_not.should include(QuietReport.new(@smelly_file.sniff, '%m%c %w (%s)').report)
  end
end

describe ShouldReekOf, 'report formatting' do
  before :each do
    sn_clean = 'def clean() @thing = 4; end'.sniff
    sn_dirty = 'def dirty() thing.cool + thing.cool; end'.sniff
    sniffers = SnifferSet.new([sn_clean, sn_dirty], '')
    @matcher = ShouldReekOf.new(:UncommunicativeName, [/Dirty/, /@s/])
    @matcher.matches?(sniffers)
    @lines = @matcher.failure_message_for_should_not.split("\n").map {|str| str.chomp}
    @error_message = @lines.shift
    @smells = @lines.grep(/^  /)
    @headers = (@lines - @smells)
  end

  it 'mentions every smell in the report' do
    @smells.should have(2).warnings
  end

  it 'doesnt mention the clean source' do
    @headers.should have(1).headers
  end
end
