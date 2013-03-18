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
      src.should_not smell_of(LongYieldList)
    end
    it 'should not report yield with few parameters' do
      src = 'def simple(arga, argb, &blk) f(3);yield a,b; end'
      src.should_not smell_of(LongYieldList)
    end
    it 'should report yield with many parameters' do
      src = 'def simple(arga, argb, &blk) f(3);yield arga,argb,arga,argb; end'
      src.should smell_of(LongYieldList, LongYieldList::PARAMETER_COUNT_KEY => 4)
    end
    it 'should not report yield of a long expression' do
      src = 'def simple(arga, argb, &blk) f(3);yield(if @dec then argb else 5+3 end); end'
      src.should_not smell_of(LongYieldList)
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
      @warning.smell['parameter_count'].should == 4
      @warning.lines.should == [3]
    end
  end
end
