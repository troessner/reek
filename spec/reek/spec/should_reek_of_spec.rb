require 'pathname'
require_relative '../../spec_helper'
require_lib 'reek/spec'

RSpec.describe Reek::Spec::ShouldReekOf do
  describe 'smell type selection' do
    let(:ruby) { 'def double_thing() @other.thing.foo + @other.thing.foo end' }

    it 'reports duplicate calls by smell type' do
      expect(ruby).to reek_of(:DuplicateMethodCall)
    end

    it 'reports duplicate calls by smell detector class' do
      expect(ruby).to reek_of(Reek::Smells::DuplicateMethodCall)
    end

    it 'does not report any feature envy' do
      expect(ruby).not_to reek_of(:FeatureEnvy)
    end
  end

  describe 'different sources of input' do
    context 'checking code in a string' do
      let(:clean_code) { 'def good() true; end' }
      let(:matcher) { Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName, name: 'y') }
      let(:smelly_code) { 'def x() y = 4; end' }

      it 'matches a smelly String' do
        expect(matcher.matches?(smelly_code)).to be_truthy
      end

      it 'doesnt match a fragrant String' do
        expect(matcher.matches?(clean_code)).to be_falsey
      end

      it 're-calculates matches every time' do
        matcher.matches? smelly_code
        expect(matcher.matches?(clean_code)).to be_falsey
      end
    end

    context 'checking code in a File' do
      let(:clean_file) { Pathname.glob("#{SAMPLES_PATH}/three_clean_files/*.rb").first }
      let(:matcher) { Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName, name: '@s') }
      let(:smelly_file) { Pathname.glob("#{SAMPLES_PATH}/two_smelly_files/*.rb").first }

      it 'matches a smelly file' do
        expect(matcher.matches?(smelly_file)).to be_truthy
      end

      it 'doesnt match a fragrant file' do
        expect(matcher.matches?(clean_file)).to be_falsey
      end
    end
  end

  describe 'smell types and smell details' do
    context 'passing in smell_details with unknown parameter name' do
      let(:matcher) { Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName, foo: 'y') }
      let(:smelly_code) { 'def x() y = 4; end' }

      it 'raises ArgumentError' do
        expect { matcher.matches?(smelly_code) }.to raise_error(ArgumentError)
      end
    end

    context 'both are matching' do
      let(:smelly_code) { 'def x() y = 4; end' }
      let(:matcher) { Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName, name: 'y') }

      it 'is truthy' do
        expect(matcher.matches?(smelly_code)).to be_truthy
      end
    end

    context 'no smell_type is matching' do
      let(:smelly_code) { 'def dummy() y = 4; end' }

      let(:falsey_matcher) { Reek::Spec::ShouldReekOf.new(:FeatureEnvy, name: 'y') }
      let(:truthy_matcher) { Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName, name: 'y') }

      it 'is falsey' do
        expect(falsey_matcher.matches?(smelly_code)).to be_falsey
      end

      it 'sets the proper error message' do
        falsey_matcher.matches?(smelly_code)

        expect(falsey_matcher.failure_message).to\
          match('Expected string to reek of FeatureEnvy, but it didn\'t')
      end

      it 'sets the proper error message when negated' do
        truthy_matcher.matches?(smelly_code)

        expect(truthy_matcher.failure_message_when_negated).to\
          match('Expected string not to reek of UncommunicativeVariableName, but it did')
      end
    end

    context 'smell type is matching but smell details are not' do
      let(:smelly_code) { 'def dummy() y = 4; end' }
      let(:matcher) { Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName, name: 'x') }

      it 'is falsey' do
        expect(matcher.matches?(smelly_code)).to be_falsey
      end

      it 'sets the proper error message' do
        matcher.matches?(smelly_code)
        expect(matcher.failure_message).to\
          match('Expected string to reek of UncommunicativeVariableName (which it did) with '\
                  'smell details {:name=>"x"}, which it didn\'t')
      end

      it 'sets the proper error message when negated' do
        matcher.matches?(smelly_code)

        expect(matcher.failure_message_when_negated).to\
          match('Expected string not to reek of UncommunicativeVariableName with smell '\
                  'details {:name=>"x"}, but it did')
      end
    end
  end

  it 'enables the smell detector to match automatically' do
    default_config = Reek::Smells::UnusedPrivateMethod.default_config
    expect(default_config[Reek::Smells::SmellConfiguration::ENABLED_KEY]).to be_falsy

    expect('class C; private; def foo; end; end').to reek_of(:UnusedPrivateMethod)
  end

  describe '#with_config' do
    let(:matcher) { Reek::Spec::ShouldReekOf.new(:UncommunicativeVariableName) }
    let(:configured_matcher) { matcher.with_config('accept' => 'x') }

    it 'uses the passed-in configuration for matching' do
      expect(configured_matcher.matches?('def foo; q = 2; end')).to be_truthy
      expect(configured_matcher.matches?('def foo; x = 2; end')).to be_falsey
    end

    it 'leaves the original matcher intact' do
      expect(configured_matcher.matches?('def foo; x = 2; end')).to be_falsey
      expect(matcher.matches?('def foo; x = 2; end')).to be_truthy
    end
  end
end
