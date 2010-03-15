require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'spec')

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
    @matcher.matches?(@smelly_code)
    @matcher.failure_message_for_should_not.should match('UncommunicativeName')
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
    @matcher.matches?(@smelly_dir)
    @matcher.failure_message_for_should_not.should match('UncommunicativeName')
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
    @matcher.matches?(@smelly_file)
    @matcher.failure_message_for_should_not.should match('UncommunicativeName')
  end
end
