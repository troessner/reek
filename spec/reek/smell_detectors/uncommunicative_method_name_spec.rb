require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/uncommunicative_method_name'

RSpec.describe Reek::SmellDetectors::UncommunicativeMethodName do
  it 'reports the right values' do
    src = <<-EOS
      def m; end
    EOS

    expect(src).to reek_of(:UncommunicativeMethodName,
                           lines:   [1],
                           context: 'm',
                           message: "has the name 'm'",
                           source:  'string',
                           name:    'm')
  end

  describe 'default configuration' do
    it 'reports one-word names' do
      src = 'def a; end'
      expect(src).to reek_of(:UncommunicativeMethodName)
    end

    it 'reports names ending with a digit' do
      src = 'def xyz1; end'
      expect(src).to reek_of(:UncommunicativeMethodName)
    end

    it 'reports camelcased names' do
      src = 'def aBBa; end'
      expect(src).to reek_of(:UncommunicativeMethodName)
    end

    it 'does not report one-letter special characters' do
      ['+', '-', '/', '*'].each do |symbol|
        expect("def #{symbol}; end").not_to reek_of(:UncommunicativeMethodName)
      end
    end
  end

  describe '`accept` patterns' do
    let(:source) { 'def x; end' }

    it 'make smelly names pass via regex / strings given by list / literal' do
      [[/x/], /x/, ['x'], 'x'].each do |pattern|
        expect(source).not_to reek_of(:UncommunicativeMethodName).with_config('accept' => pattern)
      end
    end
  end

  describe '`reject` patterns' do
    let(:source) { 'def alfa; end' }

    it 'reject smelly names via regex / strings given by list / literal' do
      [[/alfa/], /alfa/, ['alfa'], 'alfa'].each do |pattern|
        expect(source).to reek_of(:UncommunicativeMethodName).with_config('reject' => pattern)
      end
    end
  end

  describe '.default_config' do
    it 'merges in the default accept and reject patterns' do
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
    it 'is scoped to classes and modules' do
      expect(described_class.contexts).to eq([:def, :defs])
    end
  end
end
