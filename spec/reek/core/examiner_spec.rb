require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/examiner'

RSpec.shared_examples_for 'no smells found' do
  it 'is not smelly' do
    expect(@examiner).not_to be_smelly
  end
  it 'finds no smells' do
    expect(@examiner.smells.length).to eq(0)
  end
end

RSpec.shared_examples_for 'one smell found' do
  it 'is smelly' do
    expect(@examiner).to be_smelly
  end
  it 'reports the smell' do
    expect(@examiner.smells.length).to eq(1)
  end
  it 'reports the correct smell' do
    expect(@examiner.smells[0].smell_category).to eq(@expected_first_smell)
  end
end

RSpec.describe Reek::Core::Examiner do
  before :each do
    @expected_first_smell = 'NestedIterators'
  end

  context 'with a fragrant String' do
    before :each do
      @examiner = described_class.new('def good() true; end')
    end

    it_should_behave_like 'no smells found'
  end

  context 'with a smelly String' do
    before :each do
      @examiner = described_class.new('def fine() y = 4; end')
      @expected_first_smell = 'UncommunicativeName'
    end

    it_should_behave_like 'one smell found'
  end

  context 'with a partially masked smelly Dir' do
    around(:each) do |example|
      with_test_config('spec/samples/all_but_one_masked/masked.reek') do
        example.run
      end
    end

    before :each do
      smelly_dir = Dir['spec/samples/all_but_one_masked/*.rb']
      @examiner = described_class.new(smelly_dir)
    end

    it_should_behave_like 'one smell found'
  end

  context 'with a fragrant Dir' do
    before :each do
      clean_dir = Dir['spec/samples/three_clean_files/*.rb']
      @examiner = described_class.new(clean_dir)
    end

    it_should_behave_like 'no smells found'
  end

  context 'with a smelly Dir masked by a dotfile' do
    around(:each) do |example|
      with_test_config('spec/samples/masked_by_dotfile/.reek') do
        example.run
      end
    end

    before :each do
      smelly_dir = Dir['spec/samples/masked_by_dotfile/*.rb']
      @examiner = described_class.new(smelly_dir)
    end

    it_should_behave_like 'one smell found'
  end

  context 'with a partially masked smelly File' do
    around(:each) do |example|
      with_test_config('spec/samples/all_but_one_masked/masked.reek') do
        example.run
      end
    end

    before :each do
      smelly_file = File.new(Dir['spec/samples/all_but_one_masked/d*.rb'][0])
      @examiner = described_class.new(smelly_file)
    end

    it_should_behave_like 'one smell found'
  end

  context 'with a fragrant File' do
    before :each do
      clean_file = File.new(Dir['spec/samples/three_clean_files/*.rb'][0])
      @examiner = described_class.new(clean_file)
    end

    it_should_behave_like 'no smells found'
  end
end
