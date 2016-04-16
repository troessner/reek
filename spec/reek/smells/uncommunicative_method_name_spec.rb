require_relative '../../spec_helper'
require_lib 'reek/smells/uncommunicative_method_name'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::UncommunicativeMethodName do
  let(:detector) { build(:smell_detector, smell_type: :UncommunicativeMethodName) }
  it_should_behave_like 'SmellDetector'

  describe 'default configuration' do
    it 'reports one-word names' do
      expect('def a; end').to reek_of(:UncommunicativeMethodName)
    end

    it 'reports names ending with a digit' do
      expect('def xyz1; end').to reek_of(:UncommunicativeMethodName)
    end

    it 'reports camelcased names' do
      expect('def aBBa; end').to reek_of(:UncommunicativeMethodName)
    end

    it 'does not report one-letter special characters' do
      ['+', '-', '/', '*'].each do |symbol|
        expect("def #{symbol}; end").not_to reek_of(:UncommunicativeMethodName)
      end
    end
  end

  describe 'inspect' do
    let(:source) { 'def x; end' }
    let(:context) { code_context(source) }
    let(:detector) { build(:smell_detector, smell_type: :UncommunicativeMethodName) }

    it 'returns an array of smell warnings' do
      smells = detector.inspect(context)
      expect(smells.length).to eq(1)
      expect(smells[0]).to be_a_kind_of(Reek::Smells::SmellWarning)
    end

    it 'contains proper smell warnings' do
      smells = detector.inspect(context)
      warning = smells[0]

      expect(warning.smell_type).to eq(Reek::Smells::UncommunicativeMethodName.smell_type)
      expect(warning.parameters[:name]).to eq('x')
      expect(warning.context).to match(/#{warning.parameters[:name]}/)
      expect(warning.lines).to eq([1])
    end
  end

  describe '`accept` patterns' do
    let(:source) { 'def x; end' }

    it 'make smelly names pass via regex / strings given by list / literal' do
      [[/x/], /x/, ['x'], 'x'].each do |pattern|
        expect(source).to_not reek_of(described_class).with_config('accept' => pattern)
      end
    end
  end

  describe '`reject` patterns' do
    let(:source) { 'def helper; end' }

    it 'reject smelly names via regex / strings given by list / literal' do
      [[/helper/], /helper/, ['helper'], 'helper'].each do |pattern|
        expect(source).to reek_of(described_class).with_config('reject' => pattern)
      end
    end
  end

  describe '.default_config' do
    it 'should merge in the default accept and reject patterns' do
      expected = {
        'enabled' => true,
        'exclude' => [],
        'reject'  => [/^[a-z]$/, /[0-9]$/, /[A-Z]/],
        'accept'  => []
      }
      expect(described_class.default_config).to eq(expected)
    end
  end

  describe '.contexts' do
    it 'should be scoped to classes and modules' do
      expect(described_class.contexts).to eq([:def, :defs])
    end
  end
end
