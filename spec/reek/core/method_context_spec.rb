require 'spec_helper'
require 'reek/core/method_context'
require 'reek/core/stop_context'

include Reek::Core

describe MethodContext, 'matching' do
  before :each do
    exp = double('exp').as_null_object
    expect(exp).to receive(:full_name).at_least(:once).and_return('mod')
    @element = MethodContext.new(StopContext.new, exp)
  end

  it 'should recognise itself in a collection of names' do
    expect(@element.matches?(['banana', 'mod'])).to eq(true)
    expect(@element.matches?(['banana'])).to eq(false)
  end

  it 'should recognise itself in a collection of REs' do
    expect(@element.matches?([/banana/, /mod/])).to eq(true)
    expect(@element.matches?([/banana/])).to eq(false)
  end
end

describe MethodContext do
  it 'should record ivars as refs to self' do
    mctx = MethodContext.new(StopContext.new, s(:def, :feed, s(:args), nil))
    expect(mctx.envious_receivers).to eq([])
    mctx.record_call_to(s(:send, s(:ivar, :@cow), :feed_to))
    expect(mctx.envious_receivers).to eq([])
  end

  it 'should count calls to self' do
    mctx = MethodContext.new(StopContext.new, s(:def, :equals, s(:args), nil))
    mctx.refs.record_reference_to([:lvar, :other])
    mctx.record_call_to(s(:send, s(:self), :thing))
    expect(mctx.envious_receivers).to be_empty
  end

  it 'should recognise a call on self' do
    mc = MethodContext.new(StopContext.new, s(:def, :deep, s(:args), nil))
    mc.record_call_to(s(:send, s(:lvar, :text), :each, s(:arglist)))
    mc.record_call_to(s(:send, nil, :shelve, s(:arglist)))
    expect(mc.envious_receivers).to be_empty
  end
end

describe MethodParameters, 'default assignments' do
  def assignments_from(src)
    exp = src.to_reek_source.syntax_tree
    ctx = MethodContext.new(StopContext.new, exp)
    ctx.parameters.default_assignments
  end

  context 'with no defaults' do
    it 'returns an empty hash' do
      src = 'def meth(arga, argb, &blk) end'
      expect(assignments_from(src)).to be_empty
    end
  end

  context 'with 1 default' do
    before :each do
      src = 'def meth(arga, argb=456, &blk) end'
      @defaults = assignments_from(src)
    end
    it 'returns the param-value pair' do
      expect(@defaults[0]).to eq [:argb, s(:int, 456)]
    end
    it 'returns the nothing else' do
      expect(@defaults.length).to eq(1)
    end
  end

  context 'with 2 defaults' do
    before :each do
      src = 'def meth(arga=123, argb=456, &blk) end'
      @defaults = assignments_from(src)
    end
    it 'returns both param-value pairs' do
      expect(@defaults[0]).to eq [:arga, s(:int, 123)]
      expect(@defaults[1]).to eq [:argb, s(:int, 456)]
    end
    it 'returns nothing else' do
      expect(@defaults.length).to eq(2)
    end
  end
end
