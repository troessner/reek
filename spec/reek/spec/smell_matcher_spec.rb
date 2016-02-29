require_relative '../../spec_helper'
require_lib 'reek/spec/smell_matcher'

RSpec.describe Reek::Spec::SmellMatcher do
  let(:detector) { build(:smell_detector, smell_type: 'UncommunicativeVariableName') }
  let(:smell_warning) do
    build(:smell_warning, smell_detector: detector,
                          message: "has the variable name '@s'",
                          parameters: { test: 'something' })
  end
  let(:matcher) { described_class.new(smell_warning) }

  context '#matches?' do
    it 'matches on class symbol' do
      expect(matcher.matches?(:UncommunicativeVariableName)).to be_truthy
    end

    it 'matches on class symbol and params' do
      expect(matcher.matches?(:UncommunicativeVariableName,
                              test: 'something')).to be_truthy
    end

    it 'matches on class symbol, params and attributes' do
      expect(matcher.matches?(:UncommunicativeVariableName,
                              test: 'something',
                              message: "has the variable name '@s'")).to be_truthy
    end

    it 'does not match on different class symbol' do
      expect(matcher.matches?(:FeatureEnvy)).to be_falsy
    end

    it 'does not match on different params' do
      expect(matcher.matches?(:UncommunicativeVariableName,
                              test: 'something else')).to be_falsy
    end

    it 'does not match on different attributes' do
      expect(matcher.matches?(:UncommunicativeVariableName,
                              test: 'something',
                              message: 'nothing')).to be_falsy
    end

    it 'raises error on uncomparable attribute' do
      expect do
        matcher.matches?(:UncommunicativeVariableName,
                         test: 'something',
                         random: 'nothing')
      end.to raise_error("The attribute 'random' is not available for comparison")
    end
  end

  context '#matches_smell_type?' do
    it 'matches on class symbol' do
      expect(matcher.matches_smell_type?(:UncommunicativeVariableName)).to be_truthy
    end

    it 'does not match on different class symbol' do
      expect(matcher.matches_smell_type?(:FeatureEnvy)).to be_falsy
    end
  end

  context '#matches_attributes?' do
    it 'matches on params' do
      expect(matcher.matches_attributes?(test: 'something')).to be_truthy
    end

    it 'matches on class symbol, params and attributes' do
      expect(matcher.matches_attributes?(test: 'something',
                                         message: "has the variable name '@s'")).to be_truthy
    end

    it 'does not match on different params' do
      expect(matcher.matches_attributes?(test: 'something else')).to be_falsy
    end

    it 'does not match on different attributes' do
      expect(matcher.matches_attributes?(test: 'something',
                                         message: 'nothing')).to be_falsy
    end

    it 'raises error on uncomparable attribute' do
      expect do
        matcher.matches_attributes? test: 'something', random: 'nothing'
      end.to raise_error("The attribute 'random' is not available for comparison")
    end
  end
end
