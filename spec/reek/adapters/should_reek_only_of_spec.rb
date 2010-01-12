#require File.dirname(__FILE__) + '/../../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'adapters', 'report')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'adapters', 'spec')

include Reek
include Reek::Spec

describe ShouldReekOnlyOf, 'checking code in a string' do
  before :each do
    @clean_code = 'def good() true; end'
    @smelly_code = 'def fine() y = 4; end'
    @matcher = ShouldReekOnlyOf.new(:UncommunicativeVariableName, [/y/])
  end

  it 'matches a smelly String' do
    @matcher.matches?(@smelly_code).should be_true
  end

  it 'doesnt match a fragrant String' do
    @matcher.matches?(@clean_code).should be_false
  end

  it 'reports the smells when should_not fails' do
    @matcher.matches?(@smelly_code).should be_true
    @matcher.failure_message_for_should_not.should include('UncommunicativeVariableName')
  end
end

describe ShouldReekOnlyOf, 'checking code in a Dir' do
  before :each do
    @clean_dir = Dir['spec/samples/three_clean_files/*.rb']
    @smelly_dir = Dir['spec/samples/all_but_one_masked/*.rb']
    @matcher = ShouldReekOnlyOf.new(:NestedIterators, [/Dirty\#a/])
  end

  it 'matches a smelly String' do
    @matcher.matches?(@smelly_dir).should be_true
  end

  it 'doesnt match a fragrant String' do
    @matcher.matches?(@clean_dir).should be_false
  end

  it 'reports the smells when should_not fails' do
    @matcher.matches?(@smelly_dir).should be_true
    @matcher.failure_message_for_should.should include(QuietReport.new(@smelly_dir.sniff.sniffers).report)
  end
end

describe ShouldReekOnlyOf, 'checking code in a File' do
  before :each do
    @clean_file = File.new(Dir['spec/samples/three_clean_files/*.rb'][0])
    @smelly_file = File.new(Dir['spec/samples/all_but_one_masked/d*.rb'][0])
    @matcher = ShouldReekOnlyOf.new(:NestedIterators, [/Dirty\#a/])
  end

  it 'matches a smelly String' do
    @matcher.matches?(@smelly_file).should be_true
  end

  it 'doesnt match a fragrant String' do
    @matcher.matches?(@clean_file).should be_false
  end

  it 'reports the smells when should_not fails' do
    @matcher.matches?(@smelly_file).should be_true
    @matcher.failure_message_for_should.should include(QuietReport.new(@smelly_file.sniff).report)
  end
end

describe ShouldReekOnlyOf, 'report formatting' do
  before :each do
    @smelly_dir = Dir['spec/samples/all_but_one_masked/*.rb']
    @matcher = ShouldReekOnlyOf.new(:NestedIterators, [/Dirty\#a/])
    @matcher.matches?(@smelly_dir)
    @lines = @matcher.failure_message_for_should.split("\n").map {|str| str.chomp}
    @error_message = @lines.shift
    @smells = @lines.grep(/^  /)
    @headers = (@lines - @smells)
  end

  it 'doesnt mention the clean files' do
    @headers.should have(1).header
    @headers.should_not include('clean')
  end
end
