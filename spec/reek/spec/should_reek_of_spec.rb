require_relative '../../spec_helper'
require_relative '../../../lib/reek/spec'

RSpec.describe Reek::Spec::ShouldReekOf do
  context 'rdoc demo example' do
    before :each do
      @ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'
    end

    it 'reports duplicate calls to @other.thing' do
      expect(@ruby).to reek_of(:Duplication,  name: '@other.thing')
    end

    it 'reports duplicate calls to @other.thing.foo' do
      expect(@ruby).to reek_of(:Duplication,  name: '@other.thing.foo')
    end

    it 'does not report any feature envy' do
      expect(@ruby).not_to reek_of(:FeatureEnvy)
    end
  end

  context 'checking code in a string' do
    before :each do
      @clean_code = 'def good() true; end'
      @smelly_code = 'def x() y = 4; end'
      @matcher = Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName,
                                              name: 'y')
    end

    it 'matches a smelly String' do
      expect(@matcher.matches?(@smelly_code)).to be_truthy
    end

    it 'doesnt match a fragrant String' do
      expect(@matcher.matches?(@clean_code)).to be_falsey
    end

    it 'reports the smells when should_not fails' do
      expect(@matcher.matches?(@smelly_code)).to be_truthy
      expect(@matcher.failure_message_when_negated).to match('UncommunicativeVariableName')
    end
  end

  context 'passing in smell_details with unknown parameter name' do
    before :each do
      @smelly_code = 'def x() y = 4; end'
      @matcher = Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName,
                                              foo: 'y')
    end

    it 'raises ArgumentError' do
      expect { @matcher.matches?(@smelly_code) }.to raise_error(ArgumentError)
    end
  end

  context 'checking code in a Dir' do
    before :each do
      @clean_dir = Dir['spec/samples/three_clean_files/*.rb']
      @smelly_dir = Dir['spec/samples/two_smelly_files/*.rb']
      @matcher = Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName,
                                              name: '@s')
    end

    it 'matches a smelly String' do
      expect(@matcher.matches?(@smelly_dir)).to be_truthy
    end

    it 'doesnt match a fragrant String' do
      expect(@matcher.matches?(@clean_dir)).to be_falsey
    end
  end

  context 'checking code in a File' do
    before :each do
      @clean_file = File.new(Dir['spec/samples/three_clean_files/*.rb'][0])
      @smelly_file = File.new(Dir['spec/samples/two_smelly_files/*.rb'][0])
      @matcher = Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName,
                                              name: '@s')
    end

    it 'matches a smelly String' do
      expect(@matcher.matches?(@smelly_file)).to be_truthy
    end

    it 'doesnt match a fragrant String' do
      expect(@matcher.matches?(@clean_file)).to be_falsey
    end
  end
end
