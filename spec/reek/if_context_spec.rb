require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/if_context'

include Reek

describe IfContext do
  it 'should find a class within top-level code' do
    'unless jim; class Array; end; end'.should_not reek
  end

  it 'should find class within top-level code' do
    stopctx = StopContext.new
    ifctx = IfContext.new(stopctx, [:if, [:vcall, :jim]])
    ifctx.find_module(Name.new(:Array)).should_not be_nil
  end
end
