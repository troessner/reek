require 'spec_helper'
require 'reek/core/method_context'
require 'reek/core/stop_context'

include Reek::Core

describe MethodContext, 'matching' do
  before :each do
    exp = double('exp').as_null_object
    exp.should_receive(:full_name).at_least(:once).and_return('mod')
    @element = MethodContext.new(StopContext.new, exp)
  end

  it 'should recognise itself in a collection of names' do
    @element.matches?(['banana', 'mod']).should == true
    @element.matches?(['banana']).should == false
  end

  it 'should recognise itself in a collection of REs' do
    @element.matches?([/banana/, /mod/]).should == true
    @element.matches?([/banana/]).should == false
  end
end

describe MethodContext do
  it 'should record ivars as refs to self' do
    mctx = MethodContext.new(StopContext.new, ast(:defn, :feed))
    mctx.envious_receivers.should == []
    mctx.record_call_to(ast(:call, s(:ivar, :@cow), :feed_to))
    mctx.envious_receivers.should == []
  end

  it 'should count calls to self' do
    mctx = MethodContext.new(StopContext.new, ast(:defn, :equals))
    mctx.refs.record_reference_to([:lvar, :other])
    mctx.record_call_to(ast(:call, s(:self), :thing))
    mctx.envious_receivers.should be_empty
  end

  it 'should recognise a call on self' do
    mc = MethodContext.new(StopContext.new, s(:defn, :deep))
    mc.record_call_to(ast(:call, s(:lvar, :text), :each, s(:arglist)))
    mc.record_call_to(ast(:call, nil, :shelve, s(:arglist)))
    mc.envious_receivers.should be_empty
  end
end

describe MethodParameters, 'default assignments' do
  def assignments_from(src)
    exp = src.to_reek_source.syntax_tree
    ctx = MethodContext.new(StopContext.new, exp)
    return ctx.parameters.default_assignments
  end

  context 'with no defaults' do
    it 'returns an empty hash' do
      src = 'def meth(arga, argb, &blk) end'
      assignments_from(src).should be_empty
    end
  end

  context 'with 1 default' do
    before :each do
      src = "def meth(arga, argb=456, &blk) end"
      @defaults = assignments_from(src)
    end
    it 'returns the param-value pair' do
      @defaults[0].should == s(:argb, s(:lit, 456))
    end
    it 'returns the nothing else' do
      @defaults.length.should == 1
    end
  end

  context 'with 2 defaults' do
    before :each do
      src = "def meth(arga=123, argb=456, &blk) end"
      @defaults = assignments_from(src)
    end
    it 'returns both param-value pairs' do
      @defaults[0].should == s(:arga, s(:lit, 123))
      @defaults[1].should == s(:argb, s(:lit, 456))
    end
    it 'returns nothing else' do
      @defaults.length.should == 2
    end
  end
end
