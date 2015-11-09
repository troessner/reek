require_relative '../../spec_helper'
require_lib 'reek/context/code_context'
require_lib 'reek/smells/long_yield_list'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::LongYieldList do
  let(:detector) { build(:smell_detector, smell_type: :LongYieldList) }

  it_should_behave_like 'SmellDetector'

  context 'yield' do
    it 'should not report yield with no parameters' do
      src = 'def simple(arga, argb, &blk) f(3);yield; end'
      expect(src).not_to reek_of(:LongYieldList)
    end
    it 'should not report yield with few parameters' do
      src = 'def simple(arga, argb, &blk) f(3);yield a,b; end'
      expect(src).not_to reek_of(:LongYieldList)
    end
    it 'should report yield with many parameters' do
      src = 'def simple(arga, argb, &blk) f(3);yield arga,argb,arga,argb; end'
      expect(src).to reek_of(:LongYieldList, count: 4)
    end
    it 'should not report yield of a long expression' do
      src = 'def simple(arga, argb, &blk) f(3);yield(if @dec then argb else 5+3 end); end'
      expect(src).not_to reek_of(:LongYieldList)
    end
  end

  context 'when a smells is reported' do
    let(:warning) do
      src = <<-EOS
        def simple(arga, argb, &blk)
          f(3)
          yield(arga,argb,arga,argb)
          end
      EOS
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      detector.inspect(ctx).first
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the correct values' do
      expect(warning.parameters[:count]).to eq(4)
      expect(warning.lines).to eq([3])
    end
  end
end
