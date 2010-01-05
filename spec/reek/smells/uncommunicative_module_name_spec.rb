require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/method_context'
require 'reek/smells/uncommunicative_module_name'

require 'spec/reek/smells/smell_detector_shared'

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
  end

  context 'accepting names' do
    it 'accepts Inline::C' do
      ctx = mock('context')
      ctx.should_receive(:full_name).and_return('Inline::C')
      @detector.accept?(ctx).should == true
    end
  end

  context 'looking at the YAML' do
    before :each do
      src = 'module Printer2; end'
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      @mctx = CodeParser.new(sniffer).process_module(source.syntax_tree)
      @detector.examine(@mctx)
      warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
      @yaml = warning.to_yaml
    end
    it 'reports the source' do
      @yaml.should match(/source:\s*#{@source_name}/)
    end
    it 'reports the class' do
      @yaml.should match(/class:\s*UncommunicativeName/)
    end
    it 'reports the subclass' do
      @yaml.should match(/subclass:\s*UncommunicativeModuleName/)
    end
    it 'reports the variable name' do
      @yaml.should match(/module_name:\s*Printer2/)
    end
    it 'reports the line number of the declaration' do
      @yaml.should match(/lines:\s*- 1/)
    end
  end
end
