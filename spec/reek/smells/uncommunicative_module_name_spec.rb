require_relative '../../spec_helper'
require_lib 'reek/smells/uncommunicative_module_name'
require_relative 'smell_detector_shared'
require_lib 'reek/context/code_context'

RSpec.describe Reek::Smells::UncommunicativeModuleName do
  let(:detector) { build(:smell_detector, smell_type: :UncommunicativeModuleName) }
  it_should_behave_like 'SmellDetector'

  describe 'default configuration' do
    ['class', 'module'].each do |type|
      it 'does not report one-word name' do
        expect("#{type} Helper; end").not_to reek_of(:UncommunicativeModuleName)
      end

      it 'reports one-letter name' do
        expect("#{type} X; end").to reek_of(:UncommunicativeModuleName, name: 'X')
      end

      it 'reports name of the form "x2"' do
        expect("#{type} X2; end").to reek_of(:UncommunicativeModuleName, name: 'X2')
      end

      it 'reports long name ending in a number' do
        expect("#{type} Printer2; end").to reek_of(:UncommunicativeModuleName, name: 'Printer2')
      end
    end
  end

  describe 'inspect' do
    let(:source) { 'class Foo::X; end' }
    let(:context) { code_context(source) }
    let(:detector) { build(:smell_detector, smell_type: :UncommunicativeModuleName) }

    it 'returns an array of smell warnings' do
      smells = detector.inspect(context)
      expect(smells.length).to eq(1)
      expect(smells[0]).to be_a_kind_of(Reek::Smells::SmellWarning)
    end

    it 'contains proper smell warnings' do
      smells = detector.inspect(context)
      warning = smells[0]

      expect(warning.smell_type).to eq(Reek::Smells::UncommunicativeModuleName.smell_type)
      expect(warning.parameters[:name]).to eq('X')
      expect(warning.context).to match(/#{warning.parameters[:name]}/)
      expect(warning.lines).to eq([1])
    end
  end

  describe '`accept` patterns' do
    let(:source) { 'class Classy1; end' }

    it 'make smelly names pass via regex / strings given by list / literal' do
      [[/lassy/], /lassy/, ['lassy'], 'lassy'].each do |pattern|
        expect(source).to_not reek_of(described_class).with_config('accept' => pattern)
      end
    end
  end

  describe '`reject` patterns' do
    let(:source) { 'class BaseHelper; end' }

    it 'reject smelly names via regex / strings given by list / literal' do
      [[/Helper/], /Helper/, ['Helper'], 'Helper'].each do |pattern|
        expect(source).to reek_of(described_class).with_config('reject' => pattern)
      end
    end
  end

  describe '.default_config' do
    it 'should merge in the default accept and reject patterns' do
      expected = {
        'enabled' => true,
        'exclude' => [],
        'reject'  => [/^.$/, /[0-9]$/],
        'accept'  => []
      }
      expect(described_class.default_config).to eq(expected)
    end
  end

  describe '.contexts' do
    it 'should be scoped to classes and modules' do
      expect(described_class.contexts).to eq([:module, :class])
    end
  end
end
