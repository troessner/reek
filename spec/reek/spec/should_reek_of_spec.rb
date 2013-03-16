require 'spec_helper'
require 'reek/spec'

include Reek
include Reek::Spec

describe ShouldReekOf do
  context 'rdoc demo example' do
    before :each do
      @ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'
    end

    it 'reports duplicate calls to @other.thing' do
      @ruby.should reek_of(:Duplication, /@other.thing[^\.]/)
    end
    it 'reports duplicate calls to @other.thing.foo' do
      @ruby.should reek_of(:Duplication, /@other.thing.foo/)
    end
    it 'does not report any feature envy' do
      @ruby.should_not reek_of(:FeatureEnvy)
    end
  end

  context 'checking code in a string' do
    before :each do
      @clean_code = 'def good() true; end'
      @smelly_code = 'def x() y = 4; end'
      @matcher = ShouldReekOf.new(:UncommunicativeVariableName, [/x/, /y/])
    end

    it 'matches a smelly String' do
      @matcher.matches?(@smelly_code).should be_true
    end

    it 'doesnt match a fragrant String' do
      @matcher.matches?(@clean_code).should be_false
    end

    it 'reports the smells when should_not fails' do
      @matcher.matches?(@smelly_code).should be_true
      @matcher.failure_message_for_should_not.should match('UncommunicativeVariableName')
    end
  end

  context 'checking code in a Dir' do
    before :each do
      @clean_dir = Dir['spec/samples/three_clean_files/*.rb']
      @smelly_dir = Dir['spec/samples/two_smelly_files/*.rb']
      @matcher = ShouldReekOf.new(:UncommunicativeVariableName, [/Dirty/, /@s/])
    end

    it 'matches a smelly String' do
      @matcher.matches?(@smelly_dir).should be_true
    end

    it 'doesnt match a fragrant String' do
      @matcher.matches?(@clean_dir).should be_false
    end
  end

  context 'checking code in a File' do
    before :each do
      @clean_file = File.new(Dir['spec/samples/three_clean_files/*.rb'][0])
      @smelly_file = File.new(Dir['spec/samples/two_smelly_files/*.rb'][0])
      @matcher = ShouldReekOf.new(:UncommunicativeVariableName, [/Dirty/, /@s/])
    end

    it 'matches a smelly String' do
      @matcher.matches?(@smelly_file).should be_true
    end

    it 'doesnt match a fragrant String' do
      @matcher.matches?(@clean_file).should be_false
    end
  end
end
