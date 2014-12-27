require 'spec_helper'
require 'reek/examiner'

include Reek

shared_examples_for 'supports the deprecated api' do
  it 'returns all smells as active' do
    expect(@examiner.all_active_smells).to eq(@examiner.smells)
  end
  it 'returns all smells as active' do
    expect(@examiner.all_smells).to eq(@examiner.smells)
  end
  it 'counts all smells as active smells' do
    expect(@examiner.num_active_smells).to eq(@examiner.smells.length)
  end
  it 'never reports masked smells' do
    expect(@examiner.num_masked_smells).to eq(0)
  end
end

shared_examples_for 'no smells found' do
  it 'is not smelly' do
    expect(@examiner).not_to be_smelly
  end
  it 'finds no smells' do
    expect(@examiner.smells.length).to eq(0)
  end

  it_should_behave_like 'supports the deprecated api'
end

shared_examples_for 'one smell found' do
  it 'is smelly' do
    expect(@examiner).to be_smelly
  end
  it 'reports the smell' do
    expect(@examiner.smells.length).to eq(1)
  end
  it 'reports the correct smell' do
    expect(@examiner.smells[0].smell_category).to eq(@expected_first_smell)
  end

  it_should_behave_like 'supports the deprecated api'
end

describe Examiner do
  before :each do
    @expected_first_smell = 'NestedIterators'
  end

  context 'with a fragrant String' do
    before :each do
      @examiner = Examiner.new('def good() true; end')
    end

    it_should_behave_like 'no smells found'
  end

  context 'with a smelly String' do
    before :each do
      @examiner = Examiner.new('def fine() y = 4; end')
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
      @examiner = Examiner.new(smelly_dir)
    end

    it_should_behave_like 'one smell found'
  end

  context 'with a fragrant Dir' do
    before :each do
      clean_dir = Dir['spec/samples/three_clean_files/*.rb']
      @examiner = Examiner.new(clean_dir)
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
      @examiner = Examiner.new(smelly_dir)
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
      @examiner = Examiner.new(smelly_file)
    end

    it_should_behave_like 'one smell found'
  end

  context 'with a fragrant File' do
    before :each do
      clean_file = File.new(Dir['spec/samples/three_clean_files/*.rb'][0])
      @examiner = Examiner.new(clean_file)
    end

    it_should_behave_like 'no smells found'
  end
end
