require File.dirname(__FILE__) + '/../spec_helper.rb'

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
    modctx = ModuleContext.new(stop, [:module, :Fred, []])
    modctx.find_module(Name.new(:Jim)).should be_nil
  end
end
