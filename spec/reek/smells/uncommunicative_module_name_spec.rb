require 'spec_helper'
require 'reek/smells/uncommunicative_module_name'
require 'reek/smells/smell_detector_shared'
require 'reek/core/code_parser'
require 'reek/core/sniffer'

include Reek
include Reek::Smells

describe UncommunicativeModuleName do
  before :each do
    @source_name = 'classy'
    @detector = UncommunicativeModuleName.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  ['class', 'module'].each do |type|
    it 'does not report one-word name' do
      expect("#{type} Helper; end").not_to reek_of(:UncommunicativeModuleName)
    end
    it 'reports one-letter name' do
      expect("#{type} X; end").to reek_of(:UncommunicativeModuleName, /X/)
    end
    it 'reports name of the form "x2"' do
      expect("#{type} X2; end").to reek_of(:UncommunicativeModuleName, /X2/)
    end
    it 'reports long name ending in a number' do
      expect("#{type} Printer2; end").to reek_of(:UncommunicativeModuleName, /Printer2/)
    end
    it 'reports a bad scoped name' do
      src = "#{type} Foo::X; end"
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      smells = @detector.examine_context(ctx)
      expect(smells.length).to eq(1)
      expect(smells[0].smell_category).to eq(UncommunicativeModuleName.smell_category)
      expect(smells[0].smell_type).to eq(UncommunicativeModuleName.smell_type)
      expect(smells[0].parameters[:name]).to eq('X')
      expect(smells[0].context).to match(/#{smells[0].parameters[:name]}/)
    end
  end

  context 'accepting names' do
    it 'accepts Inline::C' do
      src = 'module Inline::C; end'
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      expect(@detector.examine_context(ctx)).to be_empty
    end
  end

  context 'looking at the YAML' do
    before :each do
      src = 'module Printer2; end'
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
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
