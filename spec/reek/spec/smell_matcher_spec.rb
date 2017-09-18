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
      expect(matcher).to be_matches(:UncommunicativeVariableName)
    end

    it 'matches on class symbol and params' do
      expect(matcher).to be_matches(:UncommunicativeVariableName,
                                    test: 'something')
    end

    it 'matches on class symbol, params and attributes' do
      expect(matcher).to be_matches(:UncommunicativeVariableName,
                                    test: 'something',
                                    message: "has the variable name '@s'")
    end

    it 'does not match on different class symbol' do
      expect(matcher).not_to be_matches(:FeatureEnvy)
    end

    it 'does not match on different params' do
      expect(matcher).not_to be_matches(:UncommunicativeVariableName,
                                        test: 'something else')
    end

    it 'does not match on different attributes' do
      expect(matcher).not_to be_matches(:UncommunicativeVariableName,
                                        test: 'something',
                                        message: 'nothing')
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
      expect(matcher).to be_matches_smell_type(:UncommunicativeVariableName)
    end

    it 'does not match on different class symbol' do
      expect(matcher).not_to be_matches_smell_type(:FeatureEnvy)
    end
  end

  context '#matches_attributes?' do
    it 'matches on params' do
      expect(matcher).to be_matches_attributes(test: 'something')
    end

    it 'matches on class symbol, params and attributes' do
      expect(matcher).to be_matches_attributes(test: 'something',
                                               message: "has the variable name '@s'")
    end

    it 'does not match on different params' do
      expect(matcher).not_to be_matches_attributes(test: 'something else')
    end

    it 'does not match on different attributes' do
      expect(matcher).not_to be_matches_attributes(test: 'something',
                                                   message: 'nothing')
    end

    it 'raises error on uncomparable attribute' do
      expect do
        matcher.matches_attributes? test: 'something', random: 'nothing'
      end.to raise_error("The attribute 'random' is not available for comparison")
    end
  end
end
