require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_context'
require 'reek/stop_context'

include Reek

describe MethodContext, 'matching' do
  before :each do
    @element = MethodContext.new(StopContext.new, [0, :mod])
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

describe MethodContext, 'matching fq names' do
  before :each do
    element = StopContext.new
    element = ModuleContext.new(element, [0, :mod])
    element = ClassContext.new(element, [0, :klass])
    @element = MethodContext.new(element, [0, :meth])
  end

  it 'should recognise itself in a collection of names' do
    @element.matches?(['banana', 'meth']).should == true
    @element.matches?(['banana', 'klass#meth']).should == true
    @element.matches?(['banana']).should == false
  end

  it 'should recognise itself in a collection of names' do
    @element.matches?([/banana/, /meth/]).should == true
    @element.matches?([/banana/, /klass#meth/]).should == true
    @element.matches?([/banana/]).should == false
  end
end

describe MethodContext do
  it 'should record ivars as refs to self' do
    mctx = MethodContext.new(StopContext.new, [:defn, :feed])
    mctx.envious_receivers.should == []
    mctx.record_call_to([:call, [:ivar, :@cow], :feed_to])
    mctx.envious_receivers.should == []
  end

  it 'should count calls to self' do
    mctx = MethodContext.new(StopContext.new, [:defn, :equals])
    mctx.refs.record_ref([:lvar, :other])
    mctx.record_call_to([:call, [:self], :thing])
    mctx.envious_receivers.should be_empty
  end

  it 'should recognise a call on self' do
    mc = MethodContext.new(StopContext.new, s(:defn, :deep))
    mc.record_call_to(s(:call, s(:lvar, :text), :each, s(:arglist)))
    mc.record_call_to(s(:call, nil, :shelve, s(:arglist)))
    mc.envious_receivers.should be_empty
  end
end
