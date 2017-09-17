require_relative '../../spec_helper'
require_lib 'reek/spec'

RSpec.describe Reek::Spec::ShouldReek do
  describe 'checking code in a string' do
    let(:matcher) { described_class.new }
    let(:clean_code) { 'def good() true; end' }
    let(:smelly_code) { 'def x() y = 4; end' }

    it 'matches a smelly String' do
      expect(matcher).to be_matches(smelly_code)
    end

    it 'doesnt match a fragrant String' do
      expect(matcher).not_to be_matches(clean_code)
    end

    it 'reports the smells when should_not fails' do
      matcher.matches?(smelly_code)
      expect(matcher.failure_message_when_negated).to match('UncommunicativeVariableName')
    end
  end

  describe 'checking code in a File' do
    context 'matcher without masking' do
      let(:matcher) { described_class.new }

      it 'matches a smelly File' do
        expect(matcher).to be_matches(SMELLY_FILE)
      end

      it 'doesnt match a fragrant File' do
        expect(matcher).not_to be_matches(CLEAN_FILE)
      end

      it 'reports the smells when should_not fails' do
        matcher.matches?(SMELLY_FILE)
        expect(matcher.failure_message_when_negated).to match('UncommunicativeMethodName')
      end
    end

    context 'matcher without masking' do
      let(:path) { CONFIG_PATH.join('full_mask.reek') }
      let(:configuration) { test_configuration_for(path) }
      let(:matcher) { described_class.new(configuration: configuration) }

      it 'masks smells using the relevant configuration' do
        expect(matcher).not_to be_matches(SMELLY_FILE)
      end
    end
  end
end
