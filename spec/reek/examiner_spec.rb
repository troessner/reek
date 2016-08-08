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
    expect(examiner.smells[0].smell_type).to eq(expected_first_smell)
  end
end

RSpec.describe Reek::Examiner do
  describe 'exception handling' do
    it 'catches all exceptions, wraps them in a ReekException and raises the ReekException' do
      skip
    end
  end

  let(:expected_first_smell) { 'NestedIterators' }

  context 'with a fragrant String' do
    let(:examiner) { described_class.new('def good() true; end') }

    it_should_behave_like 'no smells found'
  end

  context 'with a smelly String' do
    let(:examiner) { described_class.new('def fine() y = 4; end') }
    let(:expected_first_smell) { 'UncommunicativeVariableName' }

    it_should_behave_like 'one smell found'
  end

  context 'with a partially masked smelly File' do
    let(:configuration) { test_configuration_for(path) }
    let(:examiner) do
      described_class.new(smelly_file,
                          filter_by_smells: [],
                          configuration: configuration)
    end
    let(:path) { SAMPLES_PATH.join('all_but_one_masked/masked.reek') }
    let(:smelly_file) { Pathname.glob(SAMPLES_PATH.join('all_but_one_masked/d*.rb')).first }

    it_should_behave_like 'one smell found'
  end

  context 'with a fragrant File' do
    let(:clean_file) { Pathname.glob(SAMPLES_PATH.join('three_clean_files/*.rb')).first }
    let(:examiner) { described_class.new(clean_file) }

    it_should_behave_like 'no smells found'
  end

  describe '.new' do
    context 'returns a proper Examiner' do
      let(:source) { 'class C; def f; end; end' }
      let(:examiner) do
        described_class.new(source)
      end

      it 'has been run on the given source' do
        expect(examiner.description).to eq('string')
      end

      it 'has the right smells' do
        smells = examiner.smells
        expect(smells[0].message).to eq('has no descriptive comment')
        expect(smells[1].message).to eq("has the name 'f'")
        expect(smells[2].message).to eq("has the name 'C'")
      end

      it 'has the right smell count' do
        expect(examiner.smells_count).to eq(3)
      end
    end
  end

  describe '#smells' do
    it 'returns the detected smell warnings' do
      code     = 'def foo; bar.call_me(); bar.call_me(); end'
      examiner = described_class.new code, filter_by_smells: ['DuplicateMethodCall']

      smell = examiner.smells.first
      expect(smell).to be_a(Reek::Smells::SmellWarning)
      expect(smell.message).to eq('calls bar.call_me() 2 times')
    end

    context 'source is empty' do
      let(:source) do
        <<-EOS
            # Just a comment
            # And another
        EOS
      end
      let(:examiner) do
        described_class.new(source)
      end

      it 'has no warnings' do
        expect(examiner.smells).to eq([])
      end
    end
  end
end
