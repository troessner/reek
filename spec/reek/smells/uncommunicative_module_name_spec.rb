require_relative '../../spec_helper'
require_lib 'reek/smells/uncommunicative_module_name'

RSpec.describe Reek::Smells::UncommunicativeModuleName do
  it 'reports the right values' do
    src = <<-EOS
      class D
      end
    EOS

    expect(src).to reek_of(:UncommunicativeModuleName,
                           lines:   [1],
                           context: 'D',
                           message: "has the name 'D'",
                           source:  'string',
                           name:    'D')
  end

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

  describe '`accept` patterns' do
    let(:source) { 'class Classy1; end' }

    it 'make smelly names pass via regex / strings given by list / literal' do
      [[/lassy/], /lassy/, ['lassy'], 'lassy'].each do |pattern|
        expect(source).to_not reek_of(:UncommunicativeModuleName).with_config('accept' => pattern)
      end
    end
  end

  describe '`reject` patterns' do
    let(:source) { 'class BaseHelper; end' }

    it 'reject smelly names via regex / strings given by list / literal' do
      [[/Helper/], /Helper/, ['Helper'], 'Helper'].each do |pattern|
        expect(source).to reek_of(:UncommunicativeModuleName).with_config('reject' => pattern)
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
