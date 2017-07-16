require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/uncommunicative_parameter_name'

RSpec.describe Reek::SmellDetectors::UncommunicativeParameterName do
  it 'reports the right values' do
    src = <<-EOS
      def alfa(x)
        x
      end
    EOS

    expect(src).to reek_of(:UncommunicativeParameterName,
                           lines:   [1],
                           context: 'alfa',
                           message: "has the parameter name 'x'",
                           source:  'string',
                           name:    'x')
  end

  it 'does count all occurences' do
    src = <<-EOS
      def alfa(x, y)
        [x, y]
      end
    EOS

    expect(src).
      to reek_of(:UncommunicativeParameterName, lines: [1], name: 'x').
      and reek_of(:UncommunicativeParameterName, lines: [1], name: 'y')
  end

  { 'alfa.' => 'with a receiver',
    '' => 'without a receiver' }.each do |host, description|
    context "in a method definition #{description}" do
      it 'does not report two-letter parameter names' do
        src = "def #{host}bravo(ab); charlie(ab); end"
        expect(src).not_to reek_of(:UncommunicativeParameterName)
      end

      it 'reports names of the form "x2"' do
        src = "def #{host}bravo(x2) charlie(x2) end"
        expect(src).to reek_of(:UncommunicativeParameterName, name: 'x2')
      end

      it 'reports long name ending in a number' do
        src = "def #{host}bravo(param2) charlie(param2) end"
        expect(src).to reek_of(:UncommunicativeParameterName, name: 'param2')
      end

      it 'reports unused parameters' do
        src = "def #{host}bravo(x); charlie; end"
        expect(src).to reek_of(:UncommunicativeParameterName)
      end

      it 'reports splat parameters' do
        expect("def #{host}bravo(*a); charlie(a); end").
          to reek_of(:UncommunicativeParameterName, name: 'a')
      end

      it 'reports double splat parameters' do
        expect("def #{host}bravo(**a); charlie(a); end").
          to reek_of(:UncommunicativeParameterName, name: 'a')
      end

      it 'reports block parameters' do
        expect("def #{host}bravo(&a); charlie(a); end").
          to reek_of(:UncommunicativeParameterName, name: 'a')
      end

      it 'does not report unused anonymous parameter' do
        src = "def #{host}bravo(_); charlie; end"
        expect(src).not_to reek_of(:UncommunicativeParameterName)
      end

      it 'reports used anonymous parameter' do
        src = "def #{host}bravo(_); charlie(_) end"
        expect(src).to reek_of(:UncommunicativeParameterName, name: '_')
      end

      it 'reports used parameters marked as unused' do
        src = "def #{host}bravo(_unused) charlie(_unused) end"
        expect(src).to reek_of(:UncommunicativeParameterName, name: '_unused')
      end

      it 'does not report anonymous splat' do
        expect("def #{host}bravo(*); end").not_to reek_of(:UncommunicativeParameterName)
      end

      it 'does not report anonymous double splat' do
        expect("def #{host}bravo(**); end").not_to reek_of(:UncommunicativeParameterName)
      end

      it 'reports names inside array decomposition' do
        src = "def #{host}bravo((x, charlie)) delta(x, charlie) end"
        expect(src).to reek_of(:UncommunicativeParameterName,
                               name: 'x')
      end

      it 'reports names inside nested array decomposition' do
        src = "def #{host}bravo((charlie, (delta, x))) echo(charlie, x) end"
        expect(src).to reek_of(:UncommunicativeParameterName,
                               name: 'x')
      end
    end
  end

  describe '`accept` patterns' do
    let(:source) { 'def alfa(bar2); charlie(bar2); end' }

    it 'make smelly names pass via regex / strings given by list / literal' do
      [[/bar2/], /bar2/, ['bar2'], 'bar2'].each do |pattern|
        expect(source).not_to reek_of(:UncommunicativeParameterName).with_config('accept' => pattern)
      end
    end
  end

  describe '`reject` patterns' do
    let(:source) { 'def alfa(bravo); charlie(bravo); end' }

    it 'reject smelly names via regex / strings given by list / literal' do
      [[/bravo/], /bravo/, ['bravo'], 'bravo'].each do |pattern|
        expect(source).to reek_of(:UncommunicativeParameterName).with_config('reject' => pattern)
      end
    end
  end

  describe '.default_config' do
    it 'merges in the default accept and reject patterns' do
      expected = {
        'enabled' => true,
        'exclude' => [],
        'reject'  => [/^.$/, /[0-9]$/, /[A-Z]/, /^_/],
        'accept'  => []
      }

      expect(described_class.default_config).to eq(expected)
    end
  end

  describe '.contexts' do
    it 'indicates that this smell is scoped to method definitions' do
      expect(described_class.contexts).to eq([:def, :defs])
    end
  end
end
