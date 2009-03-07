require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'spec/reek/code_checks'
require 'reek/if_context'

include CodeChecks
include Reek

describe IfContext do
  check 'should find a class within top-level code',
    'unless jim; class Array; end; end', []

  it 'should find class within top-level code' do
    stopctx = StopContext.new
    ifctx = IfContext.new(stopctx, [:if, [:vcall, :jim]])
    ifctx.find_module(Name.new(:Array)).should_not be_nil
  end
end
