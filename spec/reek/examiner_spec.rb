require_relative '../spec_helper'
require_lib 'reek/examiner'

RSpec.shared_examples_for 'no smells found' do
  it 'is not smelly' do
    expect(examiner).not_to be_smelly
  end
  it 'finds no smells' do
    expect(examiner.smells.length).to eq(0)
  end
end

RSpec.shared_examples_for 'one smell found' do
  it 'is smelly' do
    expect(examiner).to be_smelly
  end
  it 'reports the smell' do
    expect(examiner.smells.length).to eq(1)
  end
  it 'reports the correct smell' do
    expect(examiner.smells[0].smell_category).to eq(expected_first_smell)
  end
end

RSpec.describe Reek::Examiner do
  let(:expected_first_smell) { 'NestedIterators' }

  context 'with a fragrant String' do
    let(:examiner) { described_class.new('def good() true; end') }

    it_should_behave_like 'no smells found'
  end

  context 'with a smelly String' do
    let(:examiner) { described_class.new('def fine() y = 4; end') }
    let(:expected_first_smell) { 'UncommunicativeName' }

    it_should_behave_like 'one smell found'
  end

  context 'with a partially masked smelly File' do
    let(:configuration) { test_configuration_for(path) }
    let(:examiner) { described_class.new(smelly_file, [], configuration: configuration) }
    let(:path) { SAMPLES_PATH.join('all_but_one_masked/masked.reek') }
    let(:smelly_file) { Pathname.glob(SAMPLES_PATH.join('all_but_one_masked/d*.rb')).first }

    it_should_behave_like 'one smell found'
  end

  context 'with a fragrant File' do
    let(:clean_file) { Pathname.glob(SAMPLES_PATH.join('three_clean_files/*.rb')).first }
    let(:examiner) { described_class.new(clean_file) }

    it_should_behave_like 'no smells found'
  end
end
