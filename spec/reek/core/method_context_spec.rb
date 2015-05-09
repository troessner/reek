require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/method_context'
require_relative '../../../lib/reek/core/stop_context'

RSpec.describe Reek::Core::MethodContext, 'matching' do
  before :each do
    exp = double('exp').as_null_object
    expect(exp).to receive(:full_name).at_least(:once).and_return('mod')
    @element = Reek::Core::MethodContext.new(Reek::Core::StopContext.new, exp)
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

RSpec.describe Reek::Core::MethodContext do
  let(:mc) do
    sexp = s(:def, :foo, s(:args, s(:arg, :bar)), nil)
    Reek::Core::MethodContext.new(Reek::Core::StopContext.new, sexp)
  end

  describe '#envious_receivers' do
    it 'should ignore ivars as refs to self' do
      mc.record_call_to s(:send, s(:ivar, :@cow), :feed_to)
      expect(mc.envious_receivers).to be_empty
    end

    it 'should ignore explicit calls to self' do
      mc.refs.record_reference_to [:lvar, :other]
      mc.record_call_to s(:send, s(:self), :thing)
      expect(mc.envious_receivers).to be_empty
    end

    it 'should ignore implicit calls to self' do
      mc.record_call_to s(:send, s(:lvar, :text), :each, s(:arglist))
      mc.record_call_to s(:send, nil, :shelve, s(:arglist))
      expect(mc.envious_receivers).to be_empty
    end

    it 'should record envious calls' do
      mc.record_call_to s(:send, s(:lvar, :bar), :baz)
      expect(mc.envious_receivers).to eq(bar: 1)
    end
  end
end

RSpec.describe Reek::Core::MethodParameters, 'default assignments' do
  def assignments_from(src)
    exp = Reek::Source::SourceCode.from(src).syntax_tree
    ctx = Reek::Core::MethodContext.new(Reek::Core::StopContext.new, exp)
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
