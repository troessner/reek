require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/uncommunicative_variable_name'

RSpec.describe Reek::SmellDetectors::UncommunicativeVariableName do
  it 'reports the right values' do
    src = <<-EOS
      def alfa
        x = 5
      end
    EOS

    expect(src).to reek_of(:UncommunicativeVariableName,
                           lines:   [2],
                           context: 'alfa',
                           message: "has the variable name 'x'",
                           source:  'string',
                           name:    'x')
  end

  it 'does count all occurences' do
    src = <<-EOS
      def alfa
        x = 3
        y = 7
      end
    EOS

    expect(src).to reek_of(:UncommunicativeVariableName, lines: [2], name: 'x').
      and reek_of(:UncommunicativeVariableName, lines: [3], name: 'y')
  end

  context 'instance variables' do
    it 'does not report use of one-letter names' do
      src = 'class Alfa; def bravo; @x; end; end'
      expect(src).not_to reek_of(:UncommunicativeVariableName)
    end

    it 'reports one-letter names in assignment' do
      src = 'class Alfa; def bravo(charlie) @x = charlie; end; end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: '@x')
    end
  end

  context 'local variables' do
    it 'does not report single underscore as a variable name' do
      src = 'def alfa; _ = bravo(); end'
      expect(src).not_to reek_of(:UncommunicativeVariableName)
    end

    it 'reports one-letter names' do
      src = 'def alfa; x = bravo(); end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
    end

    it 'reports names ending with a digit' do
      src = 'def alfa; var123 = bravo(); end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'var123')
    end

    it 'reports camelcased names' do
      src = 'def alfa; bravoCharlie = delta(); end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'bravoCharlie')
    end

    it 'reports a bad name inside a block' do
      src = 'def alfa; bravo.each { x = 42 }; end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
    end

    it 'reports variable name outside any method' do
      src = 'class Alfa; x = bravo(); end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
    end

    it "reports bad names starting with '_'" do
      src = 'def alfa; _bravoCharlie_42 = delta(); end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: '_bravoCharlie_42')
    end
  end

  context 'block parameters' do
    it 'reports all relevant block parameters' do
      src = <<-EOS
        def alfa
          @bravo.map { |x, y| x + y }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x').
        and reek_of(:UncommunicativeVariableName, name: 'y')
    end

    it 'reports block parameters used outside of methods' do
      src = <<-EOS
        class Alfa
          @bravo.map { |x| x * 2 }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
    end

    it 'reports splatted block parameters correctly' do
      src = <<-EOS
        def alfa
          @bravo.map { |*y| y << 1 }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
    end

    it 'reports nested block parameters' do
      src = <<-EOS
        def alfa
          @bravo.map { |(x, y)| x + y }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x').
        and reek_of(:UncommunicativeVariableName, name: 'y')
    end

    it 'reports splatted nested block parameters' do
      src = <<-EOS
        def def alfa
          @bravo.map { |(x, *y)| x + y }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x').
        and reek_of(:UncommunicativeVariableName, name: 'y')
    end

    it 'reports deeply nested block parameters' do
      src = <<-EOS
        def alfa
          @bravo.map { |(x, (y, z))| x + y + z }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x').
        and reek_of(:UncommunicativeVariableName, name: 'y').
        and reek_of(:UncommunicativeVariableName, name: 'z')
    end

    it 'reports shadowed block parameters' do
      src = <<-EOS
        def alfa
          @bravo.map { |x; y| y = x * 2 }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x').
        and reek_of(:UncommunicativeVariableName, name: 'y')
    end
  end

  describe '`accept` patterns' do
    let(:src) { 'def alfa; bravo2 = 42; end' }

    # FIXME: Move the loop out of the it?
    it 'make smelly names pass via regex / strings given by list / literal' do
      [[/bravo2/], /bravo2/, ['bravo2'], 'bravo2'].each do |pattern|
        expect(src).to reek_of(:UncommunicativeVariableName).
          and not_reek_of(:UncommunicativeVariableName).with_config('accept' => pattern)
      end
    end
  end

  describe '`reject` patterns' do
    let(:src) { 'def alfa; foobar = 42; end' }

    # FIXME: Move the loop out of the it?
    it 'reject smelly names via regex / strings given by list / literal' do
      [[/foobar/], /foobar/, ['foobar'], 'foobar'].each do |pattern|
        expect(src).to not_reek_of(:UncommunicativeVariableName).
          and reek_of(:UncommunicativeVariableName).with_config('reject' => pattern)
      end
    end
  end

  describe '.default_config' do
    it 'merges in the default accept and reject patterns' do
      expected = {
        'enabled' => true,
        'exclude' => [],
        'reject'  => [/^.$/, /[0-9]$/, /[A-Z]/],
        'accept'  => [/^_$/]
      }

      expect(described_class.default_config).to eq(expected)
    end
  end

  describe '.contexts' do
    it 'are scoped to classes, modules, instance and singleton methods' do
      expect(described_class.contexts).to eq([:module, :class, :def, :defs])
    end
  end
end
