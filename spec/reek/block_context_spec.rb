require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/block_context'
require 'reek/method_context'

include Reek

describe BlockContext do

  it "should record single parameter" do
    element = StopContext.new
    element = BlockContext.new(element, s(s(:lasgn, :x), nil))
    element.variable_names.should == [Name.new(:x)]
  end

  it "should record single parameter within a method" do
    element = StopContext.new
    element = MethodContext.new(element, s(:defn, :help))
    element = BlockContext.new(element, s(s(:lasgn, :x), nil))
    element.variable_names.should == [Name.new(:x)]
  end

  it "records multiple parameters" do
    element = StopContext.new
    element = BlockContext.new(element, s(s(:masgn, s(:array, s(:lasgn, :x), s(:lasgn, :y))), nil))
    element.variable_names.should == [Name.new(:x), Name.new(:y)]
  end

  it "should not pass parameters upward" do
    mc = MethodContext.new(StopContext.new, s(:defn, :help))
    element = BlockContext.new(mc, s(s(:lasgn, :x)))
    mc.variable_names.should be_empty
  end

  it 'records local variables' do
    bctx = BlockContext.new(StopContext.new, nil)
    bctx.record_local_variable(:q2)
    bctx.variable_names.should include(Name.new(:q2))
  end
end
