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
      "#{type} Helper; end".should_not reek_of(:UncommunicativeModuleName)
    end
    it 'reports one-letter name' do
      "#{type} X; end".should reek_of(:UncommunicativeModuleName, /X/)
    end
    it 'reports name of the form "x2"' do
      "#{type} X2; end".should reek_of(:UncommunicativeModuleName, /X2/)
    end
    it 'reports long name ending in a number' do
      "#{type} Printer2; end".should reek_of(:UncommunicativeModuleName, /Printer2/)
    end
    it 'reports a bad scoped name' do
      src = "#{type} Foo::X; end"
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      smells = @detector.examine_context(ctx)
      smells.length.should == 1
      smells[0].smell_class.should == UncommunicativeModuleName::SMELL_CLASS
      smells[0].subclass.should == UncommunicativeModuleName::SMELL_SUBCLASS
      smells[0].smell[UncommunicativeModuleName::MODULE_NAME_KEY].should == 'X'
      smells[0].context.should match(/#{smells[0].smell[UncommunicativeModuleName::MODULE_NAME_KEY]}/)
    end
  end

  context 'accepting names' do
    it 'accepts Inline::C' do
      src = 'module Inline::C; end'
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine_context(ctx).should be_empty
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
      @warning.smell[UncommunicativeModuleName::MODULE_NAME_KEY].should == 'Printer2'
      @warning.lines.should == [1]
    end
  end
end
