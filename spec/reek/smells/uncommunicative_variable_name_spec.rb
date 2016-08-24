require_relative '../../spec_helper'
require_lib 'reek/smells/uncommunicative_variable_name'

RSpec.describe Reek::Smells::UncommunicativeVariableName do
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

    expect(src).to reek_of(:UncommunicativeVariableName,
                           lines: [2],
                           name:  'x')
    expect(src).to reek_of(:UncommunicativeVariableName,
                           lines: [3],
                           name:  'y')
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

    it 'reports name of the form "x2"' do
      src = 'def alfa; x2 = bravo(); end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x2')
    end

    it 'reports long name ending in a number' do
      src = 'def alfa; var123 = bravo(); end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'var123')
    end

    it 'reports a bad name inside a block' do
      src = 'def alfa; bravo.each { x = 42 }; end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
    end

    it 'reports variable name outside any method' do
      src = 'class Alfa; x = bravo(); end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
    end
  end

  context 'block parameters' do
    it 'reports all relevant block parameters' do
      src = <<-EOS
        def alfa
          @bravo.map { |x, y| x + y }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
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

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
    end

    it 'reports splatted nested block parameters' do
      src = <<-EOS
        def def alfa
          @bravo.map { |(x, *y)| x + y }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
    end

    it 'reports deeply nested block parameters' do
      src = <<-EOS
        def alfa
          @bravo.map { |(x, (y, z))| x + y + z }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'z')
    end

    it 'reports shadowed block parameters' do
      src = <<-EOS
        def alfa
          @bravo.map { |x; y| y = x * 2 }
        end
      EOS

      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
    end
  end
end
