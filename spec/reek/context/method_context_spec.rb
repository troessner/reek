require_relative '../../spec_helper'
require_lib 'reek/context/method_context'

RSpec.describe Reek::Context::MethodContext do
  let(:method_context) { Reek::Context::MethodContext.new(nil, exp) }

  describe '#matches?' do
    let(:exp) { double('exp').as_null_object }

    before :each do
      expect(exp).to receive(:full_name).at_least(:once).and_return('mod')
    end

    it 'should recognise itself in a collection of names' do
      expect(method_context.matches?(['banana', 'mod'])).to eq(true)
      expect(method_context.matches?(['banana'])).to eq(false)
    end

    it 'should recognise itself in a collection of REs' do
      expect(method_context.matches?([/banana/, /mod/])).to eq(true)
      expect(method_context.matches?([/banana/])).to eq(false)
    end
  end

  describe '#default_assignments' do
    def assignments_from(src)
      exp = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Context::MethodContext.new(nil, exp)
      ctx.default_assignments
    end

    context 'with no defaults' do
      it 'returns an empty hash' do
        src = 'def meth(arga, argb, &blk) end'
        expect(assignments_from(src)).to be_empty
      end
    end

    context 'with 1 default' do
      let(:defaults) { assignments_from('def meth(arga, argb=456, &blk) end') }

      it 'returns the param-value pair' do
        expect(defaults[0]).to eq [:argb, sexp(:int, 456)]
      end

      it 'returns the nothing else' do
        expect(defaults.length).to eq(1)
      end
    end

    context 'with 2 defaults' do
      let(:defaults) do
        assignments_from('def meth(arga=123, argb=456, &blk) end')
      end

      it 'returns both param-value pairs' do
        expect(defaults[0]).to eq [:arga, sexp(:int, 123)]
        expect(defaults[1]).to eq [:argb, sexp(:int, 456)]
      end

      it 'returns nothing else' do
        expect(defaults.length).to eq(2)
      end
    end
  end
end
