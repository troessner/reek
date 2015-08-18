require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/uncommunicative_module_name'
require_relative 'smell_detector_shared'
require_relative '../../../lib/reek/context/code_context'

RSpec.describe Reek::Smells::UncommunicativeModuleName do
  before do
    @source_name = 'dummy_source'
    @detector = build(:smell_detector, smell_type: :UncommunicativeModuleName, source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

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

    it 'reports a bad scoped name' do
      src = "#{type} Foo::X; end"
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      smells = @detector.examine_context(ctx)
      expect(smells.length).to eq(1)
      expect(smells[0].smell_category).to eq(Reek::Smells::UncommunicativeModuleName.smell_category)
      expect(smells[0].smell_type).to eq(Reek::Smells::UncommunicativeModuleName.smell_type)
      expect(smells[0].parameters[:name]).to eq('X')
      expect(smells[0].context).to match(/#{smells[0].parameters[:name]}/)
    end
  end

  context 'accepting names' do
    it 'accepts Inline::C' do
      src = 'module Inline::C; end'
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      expect(@detector.examine_context(ctx)).to be_empty
    end
  end

  context 'looking at the YAML' do
    before :each do
      src = 'module Printer2; end'
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      smells = @detector.examine_context(ctx)
      @warning = smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the correct values' do
      expect(@warning.parameters[:name]).to eq('Printer2')
      expect(@warning.lines).to eq([1])
    end
  end
end
