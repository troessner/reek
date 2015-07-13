require_relative '../../spec_helper'
require_relative '../../../lib/reek/spec'

RSpec.describe Reek::Spec::ShouldReek do
  let(:matcher) { Reek::Spec::ShouldReek.new }

  describe 'checking code in a string' do
    let(:clean_code) { 'def good() true; end' }
    let(:smelly_code) { 'def x() y = 4; end' }

    it 'matches a smelly String' do
      expect(matcher.matches?(smelly_code)).to be_truthy
    end

    it 'doesnt match a fragrant String' do
      expect(matcher.matches?(clean_code)).to be_falsey
    end

    it 'reports the smells when should_not fails' do
      matcher.matches?(smelly_code)
      expect(matcher.failure_message_when_negated).to match('UncommunicativeVariableName')
    end
  end

  describe 'checking code in a File' do
    let(:clean_file)  { SAMPLES_PATH.join('three_clean_files/clean_one.rb')    }
    let(:smelly_file) { SAMPLES_PATH.join('two_smelly_files/dirty_one.rb')     }
    let(:masked_file) { SAMPLES_PATH.join('clean_due_to_masking/dirty_one.rb') }

    it 'matches a smelly File' do
      expect(matcher.matches?(smelly_file)).to be_truthy
    end

    it 'doesnt match a fragrant File' do
      expect(matcher.matches?(clean_file)).to be_falsey
    end

    it 'masks smells using the relevant configuration' do
      with_test_config(SAMPLES_PATH.join('clean_due_to_masking/masked.reek')) do
        expect(matcher.matches?(masked_file)).to be_falsey
      end
    end

    it 'reports the smells when should_not fails' do
      matcher.matches?(smelly_file)
      expect(matcher.failure_message_when_negated).to match('UncommunicativeVariableName')
    end
  end
end
