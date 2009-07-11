require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/spec'

include Reek::Spec

describe ShouldReekOf, 'rdoc demo example' do
  it 'works on a common source' do
    ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'.to_source
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
    @matcher.failure_message_for_should_not.should include(@smelly_code.to_source.quiet_report)
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
    @matcher.failure_message_for_should_not.should include(@smelly_dir.to_source.quiet_report)
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
    @matcher.failure_message_for_should_not.should include(@smelly_file.to_source.quiet_report)
  end
end

describe ShouldReekOf, 'report formatting' do
  before :each do
    @smelly_dir = Dir['spec/samples/mixed_results/*.rb']
    @matcher = ShouldReekOf.new(:UncommunicativeName, [/Dirty/, /@s/])
    @matcher.matches?(@smelly_dir)
    @lines = @matcher.failure_message_for_should_not.split("\n").map {|str| str.chomp}
    @error_message = @lines.shift
    @smells = @lines.grep(/^  /)
    @headers = (@lines - @smells)
  end

  it 'mentions every smell in the report' do
    @smells.should have(12).warnings
  end

  it 'doesnt mention the clean files' do
    @headers.should have(2).headers
    @headers.should_not include('clean')
  end
end
