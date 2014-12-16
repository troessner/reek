require 'spec_helper'
require 'reek/smells/long_yield_list'
require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe LongYieldList do
  before(:each) do
    @source_name = 'oo la la'
    @detector = LongYieldList.new(@source_name)
    # SMELL: can't use the default config, because that contains an override,
    # which causes the mocked matches?() method to be called twice!!
  end

  it_should_behave_like 'SmellDetector'

  context 'yield' do
    it 'should not report yield with no parameters' do
      src = 'def simple(arga, argb, &blk) f(3);yield; end'
      expect(src).not_to smell_of(LongYieldList)
    end
    it 'should not report yield with few parameters' do
      src = 'def simple(arga, argb, &blk) f(3);yield a,b; end'
      expect(src).not_to smell_of(LongYieldList)
    end
    it 'should report yield with many parameters' do
      src = 'def simple(arga, argb, &blk) f(3);yield arga,argb,arga,argb; end'
      expect(src).to smell_of(LongYieldList, count: 4)
    end
    it 'should not report yield of a long expression' do
      src = 'def simple(arga, argb, &blk) f(3);yield(if @dec then argb else 5+3 end); end'
      expect(src).not_to smell_of(LongYieldList)
    end
  end

  context 'when a smells is reported' do
    before :each do
      src = <<EOS
def simple(arga, argb, &blk)
  f(3)
  yield(arga,argb,arga,argb)
  end
EOS
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @smells = @detector.examine_context(ctx)
      @warning = @smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the correct values' do
      expect(@warning.parameters[:count]).to eq(4)
      expect(@warning.lines).to eq([3])
    end
  end
end
