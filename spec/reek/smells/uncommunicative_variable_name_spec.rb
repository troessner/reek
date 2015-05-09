require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/uncommunicative_variable_name'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::UncommunicativeVariableName do
  before :each do
    @source_name = 'dummy_source'
    @detector = build(:smell_detector,
                      smell_type: :UncommunicativeVariableName,
                      source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'field name' do
    it 'does not report use of one-letter fieldname' do
      src = 'class Thing; def simple(fred) @x end end'
      expect(src).not_to reek_of(:UncommunicativeVariableName)
    end
    it 'reports one-letter fieldname in assignment' do
      src = 'class Thing; def simple(fred) @x = fred end end'
      expect(src).to reek_of(:UncommunicativeVariableName,  name: '@x')
    end
  end

  context 'local variable name' do
    it 'does not report one-word variable name' do
      expect('def help(fred) simple = jim(45) end').
        not_to reek_of(:UncommunicativeVariableName)
    end

    it 'does not report single underscore as a variable name' do
      expect('def help(fred) _ = jim(45) end').not_to reek_of(:UncommunicativeVariableName)
    end

    it 'reports one-letter variable name' do
      src = 'def simple(fred) x = jim(45) end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
    end

    it 'reports name of the form "x2"' do
      src = 'def simple(fred) x2 = jim(45) end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x2')
    end

    it 'reports long name ending in a number' do
      @bad_var = 'var123'
      src = "def simple(fred) #{@bad_var} = jim(45) end"
      expect(src).to reek_of(:UncommunicativeVariableName,
                             name: @bad_var)
    end

    it 'reports variable name only once' do
      src = 'def simple(fred) x = jim(45); x = y end'
      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Core::CodeContext.new(nil, syntax_tree)
      smells = @detector.examine_context(ctx)
      expect(smells.length).to eq(1)
      expect(smells[0].smell_type).to eq(described_class.smell_type)
      expect(smells[0].parameters[:name]).to eq('x')
      expect(smells[0].lines).to eq([1, 1])
    end

    it 'reports a bad name inside a block' do
      src = 'def clean(text) text.each { q2 = 3 } end'
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'q2')
    end

    it 'reports variable name outside any method' do
      expect('class Simple; x = jim(45); end').to reek_of(:UncommunicativeVariableName,  name: 'x')
    end
  end

  context 'block parameter name' do
    it 'reports deep block parameter' do
      src = <<-EOS
        def bad
          unless @mod then
            @sig.each { |x| x.to_s }
          end
        end
      EOS
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
    end

    it 'reports all relevant block parameters' do
      src = <<-EOS
        def bad
          @foo.map { |x, y| x + y }
        end
      EOS
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
    end

    it 'reports block parameters used outside of methods' do
      src = <<-EOS
      class Foo
        @foo.map { |x| x * 2 }
      end
      EOS
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
    end

    it 'reports splatted block parameters correctly' do
      src = <<-EOS
        def bad
          @foo.map { |*y| y << 1 }
        end
      EOS
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
    end

    it 'reports nested block parameters' do
      src = <<-EOS
        def bad
          @foo.map { |(x, y)| x + y }
        end
      EOS
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
    end

    it 'reports splatted nested block parameters' do
      src = <<-EOS
        def bad
          @foo.map { |(x, *y)| x + y }
        end
      EOS
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
    end

    it 'reports deeply nested block parameters' do
      src = <<-EOS
        def bad
          @foo.map { |(x, (y, z))| x + y + z }
        end
      EOS
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'z')
    end

    it 'reports shadowed block parameters' do
      src = <<-EOS
        def bad
          @foo.map { |x; y| y = x * 2 }
        end
      EOS
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'x')
      expect(src).to reek_of(:UncommunicativeVariableName, name: 'y')
    end
  end

  context 'when a smell is reported' do
    before :each do
      src = <<-EOS
        def bad
          unless @mod then
             x2 = xy.to_s
             x2
             x2 = 56
          end
        end
      EOS
      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Core::CodeContext.new(nil, syntax_tree)
      @smells = @detector.examine_context(ctx)
      @warning = @smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the correct values' do
      expect(@warning.parameters[:name]).to eq('x2')
      expect(@warning.lines).to eq([3, 5])
    end
  end

  context 'when a smell is reported in a singleton method' do
    before :each do
      src = 'def self.bad() x2 = 4; end'
      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Core::CodeContext.new(nil, syntax_tree)
      @smells = @detector.examine_context(ctx)
      @warning = @smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the fq context' do
      expect(@warning.context).to eq('self.bad')
    end
  end
end
