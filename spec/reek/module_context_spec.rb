require 'spec/reek/code_checks'
require 'reek/module_context'

include CodeChecks
include Reek

describe ModuleContext do
  check 'should report module name for smell in method',
    'module Fred; def simple(x) true; end; end', [[/x/, /simple/, /Fred/]]

  check 'should not report module with empty class',
    'module Fred; class Jim; end; end', []

  it 'should handle module with empty class' do
    stop = StopContext.new
    modctx = ModuleContext.create(stop, [:module, :Fred, []])
    modctx.find_module(Name.new(:Jim)).should be_nil
  end
end

describe ModuleContext do
  check 'should recognise global constant',
    'module ::Global class Inside; end; end', []

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
