require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/uncommunicative_module_name'

RSpec.describe Reek::SmellDetectors::UncommunicativeModuleName do
  it 'reports the right values' do
    src = <<-EOS
      class K
      end
    EOS

    expect(src).to reek_of(:UncommunicativeModuleName,
                           lines:   [1],
                           context: 'K',
                           message: "has the name 'K'",
                           source:  'string',
                           name:    'K')
  end

  describe 'default configuration' do
    ['class', 'module'].each do |type|
      it 'does not report one-word name' do
        expect("#{type} Alfa; end").not_to reek_of(:UncommunicativeModuleName)
      end

      it 'reports one-letter name' do
        expect("#{type} X; end").to reek_of(:UncommunicativeModuleName, name: 'X')
      end

      it 'reports name of the form "x2"' do
        expect("#{type} X2; end").to reek_of(:UncommunicativeModuleName, name: 'X2')
      end

      it 'reports long name ending in a number' do
        expect("#{type} Alfa2; end").to reek_of(:UncommunicativeModuleName, name: 'Alfa2')
      end
    end
  end

  describe '`accept` patterns' do
    let(:source) { 'class Alfa1; end' }

    it 'makes smelly names pass via regex / strings given by list / literal' do
      [[/lfa/], /lfa/, ['lfa'], 'lfa'].each do |pattern|
        expect(source).not_to reek_of(:UncommunicativeModuleName).with_config('accept' => pattern)
      end
    end
  end

  describe '`reject` patterns' do
    let(:source) { 'class Alfa; end' }

    it 'rejects smelly names via regex / strings given by list / literal' do
      [[/Alfa/], /Alfa/, ['Alfa'], 'Alfa'].each do |pattern|
        expect(source).to reek_of(:UncommunicativeModuleName).with_config('reject' => pattern)
      end
    end
  end

  describe '.default_config' do
    it 'merges in the default accept and reject patterns' do
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
    it 'indicates that this smell is scoped to classes and modules' do
      expect(described_class.contexts).to eq([:module, :class])
    end
  end
end
