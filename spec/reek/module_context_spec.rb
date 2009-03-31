require File.dirname(__FILE__) + '/../spec_helper.rb'
require 'reek/module_context'
require 'reek/stop_context'

include Reek

describe ModuleContext do
  it 'should report module name for smell in method' do
    'module Fred; def simple(x) true; end; end'.should reek_of(:UncommunicativeName, /x/, /simple/, /Fred/)
  end

  it 'should not report module with empty class' do
    'module Fred; class Jim; end; end'.should_not reek
  end

  it 'should handle module with empty class' do
    stop = StopContext.new
    modctx = ModuleContext.create(stop, [:module, :Fred, []])
    modctx.find_module(Name.new(:Jim)).should be_nil
  end
end

describe ModuleContext do
  it 'should recognise global constant' do
    'module ::Global class Inside; end; end'.should_not reek
  end

  it 'should not find missing global constant' do
    element = ModuleContext.create(StopContext.new, [:module, [:colon3, :Global], nil])
    element.myself.should be_nil
  end

  it 'should find global constant' do
    module ::GlobalTestModule; end
    element = ModuleContext.create(StopContext.new, [:module, [:colon3, :GlobalTestModule], nil])
    element.myself.name.should == 'GlobalTestModule'
  end
end
